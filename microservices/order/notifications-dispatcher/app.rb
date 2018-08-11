require 'json'

require_relative "../../../ruby/lib/printExecutionTime"
require_relative "../../../ruby/lib/config"

require_relative "../../../ruby/repositories/Mongo/lib/connect"
require_relative "../../../ruby/entities/OrderUserEntity"
require_relative "../../../ruby/repositories/Mongo/OrderMongoRepository"
require_relative "../../../ruby/dataProvider/OrderDataProvider"

require_relative '../../../ruby/lib/MessageBroker/MessageBroker'
require_relative '../../../ruby/lib/MessageBroker/dispatchers/RabbitMQ/RabbitMQDispatcher'
require_relative '../../../ruby/lib/MessageBroker/Routing'

dispatcher = RabbitMQDispatcher.new(host: config["rabbitmq"]["host"])
messageBroker = MessageBroker.new(dispatcher: dispatcher)

begin
  messageBroker.connect
rescue MessageBrokerConnectionRefused
  abort "RabbitMQ connection refused"
end 

begin
  mongo = mongoConnect(
    host: config["mongodb"]["host"], 
    port: config["mongodb"]["port"], 
    user: config["mongodb"]["username"], 
    password: config["mongodb"]["password"], 
    database: config["mongodb"]["database"]
  )
rescue => e
  puts e
end

printExecutionTime

orderTopic = messageBroker.createTopic(name: "order", routing: Routing.PatternMatching)
onOrderPlaced = orderTopic.createRoom(name: "placed")

orderMongoRepository = OrderMongoRepository.new(mongo: mongo)
orderDataProvider = OrderDataProvider.new(repository: orderMongoRepository)

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
 
  resOrderEntity = orderDataProvider.addEmail(uid: order["uid"], receipt: "oij45tkj8d4G-Wed5")
}