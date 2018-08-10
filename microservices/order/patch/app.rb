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

mongo = mongoConnect(
  host: config["mongodb"]["host"], 
  port: config["mongodb"]["port"], 
  user: config["mongodb"]["username"], 
  password: config["mongodb"]["password"], 
  database: config["mongodb"]["database"]
)

printExecutionTime

topic = messageBroker.createTopic(name: "order", routing: Routing.PatternMatching)
onPatchOrder = topic.createRoom(name: "patch.*")

orderMongoRepository = OrderMongoRepository.new(mongo: mongo)
orderDataProvider = OrderDataProvider.new(repository: orderMongoRepository)

onPatchOrder.subscribe { |delivery_info, properties, payload|
  puts " [x] Received #{payload}"

  payloadData = JSON.parse payload

  # TODO: Add a payload data parser and mapper
  
  uid = payloadData["uid"]
  patch = payloadData["patch"]
  operation = nil

  if delivery_info.routing_key == "patch.replace"
    operation = OrderDataProvider.PatchReplace
  elsif delivery_info.routing_key == "patch.add"
    operation = OrderDataProvider.PatchAdd
  end  

  # TODO: Check if operation is nil

  resOrderEntity = orderDataProvider.patch(uid: uid, operation: operation, patch: patch)

  topic.publish(room: "patched", payload: resOrderEntity.to_json)
}