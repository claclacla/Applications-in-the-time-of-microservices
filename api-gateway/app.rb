require 'sinatra'

require_relative '../lib/MessageBroker/MessageBroker'
require_relative '../lib/MessageBroker/dispatchers/RabbitMQ/RabbitMQDispatcher'

set :bind, '0.0.0.0'

dispatcher = RabbitMQDispatcher.new(host: "rabbitmq")
messageBroker = MessageBroker.new(dispatcher: dispatcher)

begin
  messageBroker.connect
rescue MessageBrokerConnectionRefused
  abort "RabbitMQ connection refused"
end  

post '/order' do
  channel = messageBroker.createChannel(name: "order.place") 
  channel.publish(body: "Place a new order")
end