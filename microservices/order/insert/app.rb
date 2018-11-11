require 'json'

require_relative "../../../ruby/lib/printExecutionTime"
require_relative "../../../ruby/lib/config"

require_relative "../../../ruby/repositories/Mongo/lib/connect"
require_relative "../../../ruby/entities/OrderUserEntity"
require_relative "../../../ruby/repositories/Mongo/OrderMongoRepository"
require_relative "../../../ruby/dataProvider/OrderDataProvider"

require 'postcard_rb'
require 'postcard_rb/errors/PostcardConnectionRefused'
require 'postcard_rb/dispatchers/RabbitMQ/RabbitMQDispatcher'
require 'postcard_rb/Routing'

dispatcher = RabbitMQDispatcher.new(host: config["rabbitmq"]["host"])
postcardRB = PostcardRB.new(dispatcher: dispatcher)

begin
  postcardRB.connect
rescue PostcardConnectionRefused
  abort "RabbitMQ connection refused"
end  

mongo = mongoConnect(
  host: config["mongodb"]["host"], 
  port: config["mongodb"]["port"], 
  user: config["mongodb"]["username"], 
  password: config["mongodb"]["password"], 
  database: config["mongodb"]["database"]
)

printExecutionTime

topic = postcardRB.createTopic(name: "order", routing: Routing.PatternMatching)
onPlaceOrder = topic.createRoom(name: "place")

orderMongoRepository = OrderMongoRepository.new(mongo: mongo)
orderDataProvider = OrderDataProvider.new(repository: orderMongoRepository)

onPlaceOrder.subscribe { |delivery_info, properties, payload|
  puts " [x] Received #{payload}"

  order = JSON.parse payload

  orderUserEntity = OrderUserEntity.new(
    name: order["user"]["name"],
    email: order["user"]["email"],
    mobile: order["user"]["mobile"]
  )

  resOrderEntity = orderDataProvider.place(orderUserEntity: orderUserEntity)

  topic.publish(room: "placed", payload: resOrderEntity.to_json)
}