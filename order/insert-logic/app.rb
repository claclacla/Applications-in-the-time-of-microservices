require 'json'

require_relative '../../ruby/lib/MessageBroker/MessageBroker'
require_relative '../../ruby/lib/MessageBroker/dispatchers/RabbitMQ/RabbitMQDispatcher'
require_relative '../../ruby/lib/MessageBroker/Routing'

dispatcher = RabbitMQDispatcher.new(host: "rabbitmq")
messageBroker = MessageBroker.new(dispatcher: dispatcher)

begin
  messageBroker.connect
rescue MessageBrokerConnectionRefused
  abort "RabbitMQ connection refused"
end  

topic = messageBroker.createTopic(name: "order", routing: Routing.Explicit)
onPlaceOrder = topic.createRoom(name: "on.place")

orderNumber = 1

onPlaceOrder.subscribe { |properties, payload|
  puts " [x] Received #{payload}"

  # Order insert logic operations

  # ...

  order = JSON.parse payload
  order["number"] = orderNumber

  orderNumber += 1

  # ...

  topic.publish(room: "on.placed", payload: order.to_json)
}