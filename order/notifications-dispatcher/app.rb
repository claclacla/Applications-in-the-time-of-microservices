require 'json'
require 'net/http'

require_relative "../../ruby/lib/printExecutionTime"
require_relative "../../ruby/lib/config"

require_relative '../../ruby/lib/MessageBroker/MessageBroker'
require_relative '../../ruby/lib/MessageBroker/dispatchers/RabbitMQ/RabbitMQDispatcher'
require_relative '../../ruby/lib/MessageBroker/Routing'

dispatcher = RabbitMQDispatcher.new(host: config["rabbitmq"]["host"])
messageBroker = MessageBroker.new(dispatcher: dispatcher)

begin
  messageBroker.connect
rescue MessageBrokerConnectionRefused
  abort "RabbitMQ connection refused"
end 

printExecutionTime

orderTopic = messageBroker.createTopic(name: "order", routing: Routing.Explicit)
onOrderPlaced = orderTopic.createRoom(name: "placed")

messageTopic = messageBroker.createTopic(name: "message", routing: Routing.Explicit)

onOrderPlaced.subscribe { |delivery_info, properties, payload|
  puts " [x] Received #{payload}"

  order = JSON.parse payload
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
  emailSentData = {
    "order" => {
      "number" => order["number"]
    },
    "receipt" => {
      "code" => "oij45tkj8d4G-Wed5" #dispatcherManagerReceipt["code"]
    }
  }
 
  messageTopic.publish(room: "email.sent", payload: emailSentData.to_json)
}