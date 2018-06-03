require_relative '../../lib/MessageBroker/MessageBroker'
require_relative '../../lib/MessageBroker/dispatchers/RabbitMQ/RabbitMQDispatcher'

dispatcher = RabbitMQDispatcher.new(host: "rabbitmq")
messageBroker = MessageBroker.new(dispatcher: dispatcher)

puts "Order notification dispatcher: start"

begin
  messageBroker.connect
rescue MessageBrokerConnectionRefused
  abort "RabbitMQ connection refused"
end  

orderPlacedChannel = messageBroker.createChannel(name: "order.placed") 
orderPlacedChannel.subscribe { |body|
  puts " [x] Received #{body}"

  dispatcherSendEmailChannel = messageBroker.createChannel(name: "dispatcher.send.email") 
  dispatcherSendEmailChannel.publish(body: "Send a new email")
}