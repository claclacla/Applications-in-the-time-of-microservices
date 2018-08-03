require 'json'

require_relative "../../../ruby/lib/printExecutionTime"
require_relative "../../../ruby/lib/config"

require_relative '../../../ruby/lib/MessageBroker/MessageBroker'
require_relative '../../../ruby/lib/MessageBroker/dispatchers/RabbitMQ/RabbitMQDispatcher'
require_relative '../../../ruby/lib/MessageBroker/Routing'

dispatcher = RabbitMQDispatcher.new(host: config["rabbitmq"]["host"])
messageBroker = MessageBroker.new(dispatcher: dispatcher)

begin
  messageBroker.connect
rescue MessageBrokerConnectionRefused
  abort "RabbitMQ connection refused"
end  

printExecutionTime

topic = messageBroker.createTopic(name: "order", routing: Routing.Explicit)
onPlaceOrder = topic.createRoom(name: "place")

orderNumber = 1

onPlaceOrder.subscribe { |delivery_info, properties, payload|
  puts " [x] Received #{payload}"

  # Order insert logic operations

  # ...

  order = JSON.parse payload
  order["number"] = orderNumber

  orderNumber += 1

  # ...

  puts "Order placed"
  topic.publish(room: "placed", payload: order.to_json)
}