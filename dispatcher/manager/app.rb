require_relative '../../lib/MessageBroker/MessageBroker'
require_relative '../../lib/MessageBroker/dispatchers/RabbitMQ/RabbitMQDispatcher'

dispatcher = RabbitMQDispatcher.new(host: "rabbitmq")
messageBroker = MessageBroker.new(dispatcher: dispatcher)

begin
  messageBroker.connect
rescue MessageBrokerConnectionRefused
  abort "RabbitMQ connection refused"
end  

channel = messageBroker.createChannel(name: "dispatcher") 
channel.subscribe { |body|
  puts " [x] Received #{body}"
}