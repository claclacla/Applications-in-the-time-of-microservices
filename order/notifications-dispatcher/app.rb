require 'json'
require 'net/http'

require_relative '../../lib/MessageBroker/MessageBroker'
require_relative '../../lib/MessageBroker/dispatchers/RabbitMQ/RabbitMQDispatcher'
require_relative '../../lib/MessageBroker/Routing'

dispatcher = RabbitMQDispatcher.new(host: "rabbitmq")
messageBroker = MessageBroker.new(dispatcher: dispatcher)

begin
  messageBroker.connect
rescue MessageBrokerConnectionRefused
  abort "RabbitMQ connection refused"
end 

orderTopic = messageBroker.createTopic(name: "order", routing: Routing.Explicit)
onOrderPlaced = orderTopic.createRoom(name: "on.placed")

onOrderPlaced.subscribe { |properties, payload|
  puts " [x] Received #{payload}"

  order = JSON.parse payload
  message = {
    "from" => "info@shop.com",
    "to" => order["user"]["email"],
    "title" => "New order",
    "body" => "New order"
  }

  # TODO: write a repository for this internal service

  url = URI.parse('http://dispatcher-manager:4567/email')

  header = {'Content-Type': 'text/json'}

  req = Net::HTTP::Post.new(url.to_s, header)
  req.body = message.to_json

  res = Net::HTTP.start(url.host, url.port) {|http|
    http.request(req)
  }

  puts res.body
  #dispatcherTopic.publish(room: "send.email", payload: "Send a new email")
}