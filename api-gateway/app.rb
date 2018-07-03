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
  #topic = messageBroker.createTopic(name: "order", routing: Routing.Wide)
  #topic.publish(payload: "Place a new order")
  #topic = messageBroker.createTopic(name: "order", routing: Routing.Explicit)
  #topic.publish(room: "place", payload: "Place a new order")
  topic = messageBroker.createTopic(name: "order", routing: Routing.PatternMatching)
  topic.publish(room: "place.new", payload: "Place a new order")
end