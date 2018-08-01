require 'json'
require 'net/http'

require_relative '../../ruby/lib/MessageBroker/MessageBroker'
require_relative '../../ruby/lib/MessageBroker/dispatchers/RabbitMQ/RabbitMQDispatcher'
require_relative '../../ruby/lib/MessageBroker/Routing'

dispatcher = RabbitMQDispatcher.new(host: "rabbitmq")
messageBroker = MessageBroker.new(dispatcher: dispatcher)

begin
  messageBroker.connect
rescue MessageBrokerConnectionRefused
  abort "RabbitMQ connection refused"
end 

puts "start"

orderTopic = messageBroker.createTopic(name: "order", routing: Routing.Explicit)
onOrderPlaced = orderTopic.createRoom(name: "on.placed")

onOrderPlaced.subscribe { |delivery_info, properties, payload|
  puts "on placed"
  puts " [x] Received #{payload}"

#  order = JSON.parse payload
#
#  # TODO: Create a DTO for this object
#
#  message = {
#    "from" => "info@shop.com",
#    "to" => order["user"]["email"],
#    "title" => "New order",
#    "body" => "New order"
#  }
#
#  # TODO: write a repository for this internal service
#
#  url = URI.parse('http://dispatcher-manager:4567/email')
#
#  header = {'Content-Type': 'text/json'}
#
#  req = Net::HTTP::Post.new(url.to_s, header)
#  req.body = message.to_json
#
#  res = Net::HTTP.start(url.host, url.port) {|http|
#    http.request(req)
#  }
#
#  # TODO: Add a response verification
#
#  dispatcherManagerReceipt = JSON.parse res.body
#
#  # TODO: Create a DTO for this object
#
#  emailSentData = {
#    "order" => {
#      "number" => order["number"]
#    },
#    "receipt" => {
#      "code" => dispatcherManagerReceipt["code"]
#    }
#  }
#
#  orderTopic.publish(room: "on.email.sent", payload: emailSentData.to_json)
}