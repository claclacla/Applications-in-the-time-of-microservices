require 'json'
require 'goliath'

require_relative '../ruby/lib/MessageBroker/MessageBroker'
require_relative '../ruby/lib/MessageBroker/dispatchers/RabbitMQ/RabbitMQDispatcher'
require_relative '../ruby/lib/MessageBroker/Routing'

class HelloWorld < Goliath::API
  def response(env)
    req = EM::HttpRequest.new("http://www.google.com/").get
    resp = req.response

    [200, {}, resp]
  end
end

#set :bind, '0.0.0.0'
#$stdout.sync = true
#
#dispatcher = RabbitMQDispatcher.new(host: "rabbitmq")
#messageBroker = MessageBroker.new(dispatcher: dispatcher)
#
#begin
#  messageBroker.connect
#rescue MessageBrokerConnectionRefused
#  abort "RabbitMQ connection refused"
#end  
#
#topic = messageBroker.createTopic(name: "order", routing: Routing.Explicit)
#onOrderPlaced = topic.createRoom(name: "on.placed")

#onOrderPlaced.subscribe(block: true) { |delivery_info, properties, payload|
#  puts "subscribe 2" 
#}

# TODO: Create the Order DTO and Entity with their mappers 
# TODO: Add a response to this endpoint
# TODO: This endpoint may have a response with a 201 status

#post '/order' do
#  #order = JSON.parse request.body.read
#
#  puts "Place an order"
#  #topic.publish(room: "on.place", payload: order.to_json)
#  topic.publish(room: "on.place", payload: "order.to_json")
#
#  stream :keep_open do |out|
#    EventMachine::PeriodicTimer.new(1) { out << "#{Time.now}\n" }
#  end  
#end