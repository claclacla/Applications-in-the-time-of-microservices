require_relative '../../lib/MessageBroker/MessageBroker'
require_relative '../../lib/MessageBroker/dispatchers/RabbitMQ/RabbitMQDispatcher'

dispatcher = RabbitMQDispatcher.new(host: "rabbitmq")
messageBroker = MessageBroker.new(dispatcher: dispatcher)

puts "Dispatcher manager: start"

begin
  messageBroker.connect
rescue MessageBrokerConnectionRefused
  abort "RabbitMQ connection refused"
end  

puts "Dispatcher manager: subscribe messages"

#channel = messageBroker.createChannel(name: "dispatcher.send.email") 
#channel.subscribe { |body|
#  puts "Dispatcher manager: Received #{body}"
#}