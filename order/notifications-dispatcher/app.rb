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

puts "Order notification dispatcher: subscribe messages"

orderLogicChannel = messageBroker.createChannel(name: "order.placed") 
orderLogicChannel.subscribe { |body|
  puts "Order notification dispatcher: Received #{body}"

#  dispatcherChannel = messageBroker.createChannel(name: "dispatcher.send.email") 
#  dispatcherChannel.publish(body: "Dispatch a mail")
}