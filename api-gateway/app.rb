require 'sinatra'

require_relative '../lib/MessageBroker/MessageBroker'
require_relative '../lib/MessageBroker/dispatchers/RabbitMQ/RabbitMQDispatcher'
require_relative '../lib/MessageBroker/Routing'

set :bind, '0.0.0.0'

dispatcher = RabbitMQDispatcher.new(host: "rabbitmq")
messageBroker = MessageBroker.new(dispatcher: dispatcher)

begin
  messageBroker.connect
rescue MessageBrokerConnectionRefused
  abort "RabbitMQ connection refused"
end  

post '/order' do
  messageBroker.createTopic(name: "order.place", routing: Routing.Wide)
  #channel.publish(body: "Place a new order")
end