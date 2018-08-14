require 'json'

require_relative "../../../ruby/lib/printExecutionTime"
require_relative "../../../ruby/lib/config"

require_relative "../../../ruby/repositories/Mongo/lib/connect"
require_relative "../../../ruby/repositories/Mongo/OrderMongoRepository"
require_relative "../../../ruby/dataProvider/OrderDataProvider"
require_relative "../../../ruby/entities/EmailEntity"
require_relative "../../../ruby/dtos/DispatcherManagerEmailPlaceDto"

require_relative '../../../ruby/lib/MessageBroker/MessageBroker'
require_relative '../../../ruby/lib/MessageBroker/dispatchers/RabbitMQ/RabbitMQDispatcher'
require_relative '../../../ruby/lib/MessageBroker/Routing'
require_relative "../../../ruby/lib/MessageBroker/lib/CorrelationID"

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

orderMongoRepository = OrderMongoRepository.new(mongo: mongo)
orderDataProvider = OrderDataProvider.new(repository: orderMongoRepository)

# order

orderTopic = messageBroker.createTopic(name: "order", routing: Routing.PatternMatching)
onOrderPlaced = orderTopic.createRoom(name: "placed")

# subscribe to the dispatcher-manager topic

dispatcherManagerTopic = messageBroker.createTopic(name: "dispatcher-manager", routing: Routing.Explicit)

onEmailPlaced = dispatcherManagerTopic.createRoom(name: "email.placed")

onEmailPlaced.subscribe(block: false) { |delivery_info, properties, payload|
  orderDataProvider.setEmailStatus(
    caseNumber: properties[:correlation_id], 
    status: EmailEntity.RequestAccepted
  )
}

onOrderPlaced.subscribe { |delivery_info, properties, payload|
  puts " [x] Received #{payload}"

  order = JSON.parse payload

  # publish the email data

  dispatcherManagerEmailPlaceDto = DispatcherManagerEmailPlaceDto.new(
    from: config["contacts"]["email"],
    to: order["user"]["email"],
    title: "New order",
    body: "New order"
  )
 
  dispatcherManagerTopic.publish(
    room: "email.place", 
    payload: dispatcherManagerEmailPlaceDto.to_json,
    correlationId: dispatcherManagerEmailPlaceDto.caseNumber,
    replyTo: "email.placed"
  )

  # attach email case number to the order

  orderDataProvider.attachEmail(
    uid: order["uid"], 
    caseNumber: dispatcherManagerEmailPlaceDto.caseNumber
  )
}