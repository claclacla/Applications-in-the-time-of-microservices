require 'json'

require_relative "../../../ruby/lib/printExecutionTime"
require_relative "../../../ruby/lib/config"

require_relative "../../../ruby/repositories/Mongo/lib/connect"
require_relative "../../../ruby/repositories/Mongo/OrderMongoRepository"
require_relative "../../../ruby/dataProvider/OrderDataProvider"
require_relative "../../../ruby/entities/EmailEntity"
require_relative "../../../ruby/dtos/DispatcherManagerEmailPlaceRequestDto"
require_relative "../../../ruby/dtos/DispatcherManagerPlaceResponseDto"

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

orderMongoRepository = OrderMongoRepository.new(mongo: mongo)
orderDataProvider = OrderDataProvider.new(repository: orderMongoRepository)

# order

orderTopic = postcardRB.createTopic(name: "order", routing: Routing.PatternMatching)
onOrderPlaced = orderTopic.createRoom(name: "placed")

# subscribe to the dispatcher-manager topic

dispatcherManagerTopic = postcardRB.createTopic(name: "dispatcher-manager", routing: Routing.PatternMatching)

onPlaceEmailResponse = dispatcherManagerTopic.createRoom(name: "message.place.response.email")

onPlaceEmailResponse.subscribe(block: false) { |delivery_info, properties, payload|
  placeResponse = JSON.parse payload

  # TODO: Handle the Errored case

  if placeResponse["status"] == DispatcherManagerPlaceResponseDto.Placed
    orderDataProvider.setEmailStatus(
      caseNumber: properties[:correlation_id], 
      status: EmailEntity.RequestAccepted
    )
  end
}

onOrderPlaced.subscribe { |delivery_info, properties, payload|
  puts " [x] Received #{payload}"

  order = JSON.parse payload

  # publish the email data

  dispatcherManagerEmailPlaceRequestDto = DispatcherManagerEmailPlaceRequestDto.new(
    from: config["contacts"]["email"],
    to: order["user"]["email"],
    title: "New order",
    body: "New order"
  )
 
  dispatcherManagerTopic.publish(
    room: "message.place.request.email", 
    payload: dispatcherManagerEmailPlaceRequestDto.to_json,
    correlationId: dispatcherManagerEmailPlaceRequestDto.caseNumber,
    replyTo: "message.place.response.email"
  )

  # attach email case number to the order

  orderDataProvider.attachEmail(
    uid: order["uid"], 
    caseNumber: dispatcherManagerEmailPlaceRequestDto.caseNumber
  )
}