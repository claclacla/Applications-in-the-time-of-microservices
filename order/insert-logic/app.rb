require_relative '../../lib/MessageBroker/MessageBroker'
require_relative '../../lib/MessageBroker/dispatchers/RabbitMQ/RabbitMQDispatcher'

dispatcher = RabbitMQDispatcher.new(host: "rabbitmq")
messageBroker = MessageBroker.new(dispatcher: dispatcher)

begin
  messageBroker.connect
rescue MessageBrokerConnectionRefused
  abort "RabbitMQ connection refused"
end  

orderPlaceChannel = messageBroker.createChannel(name: "order.place") 
orderPlaceChannel.subscribe { |properties, payload|
  puts " [x] Received #{payload}"

  orderPlacedChannel = messageBroker.createChannel(name: "order.placed") 
  orderPlacedChannel.publish(body: "New order placed")
}