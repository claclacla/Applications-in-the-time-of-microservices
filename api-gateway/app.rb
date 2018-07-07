require 'json'
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

topic = messageBroker.createTopic(name: "order", routing: Routing.Explicit)

# TODO: Create the Order DTO and Entity with their mappers 
# TODO: Add a response to this endpoint
# TODO: This endpoint may have a response with a 201 status

post '/order' do
  order = JSON.parse request.body.read

  topic.publish(room: "on.place", payload: JSON.generate(order))
end