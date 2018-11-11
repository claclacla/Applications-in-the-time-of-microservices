require 'json'

require_relative "../../../ruby/lib/printExecutionTime"
require_relative "../../../ruby/lib/config"

require_relative "../../../ruby/dtos/DispatcherManagerPlaceResponseDto"
require_relative "../../../ruby/dtos/DispatcherManagerEmailSendRequestDto"
require_relative "../../../ruby/dtos/DispatcherManagerSendResponseDto"
require_relative "../../../ruby/dtos/DispatcherManagerEmailSentDto"

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

printExecutionTime

dispatcherManagerTopic = postcardRB.createTopic(name: "dispatcher-manager", routing: Routing.PatternMatching)
onSendResponse = dispatcherManagerTopic.createRoom(name: "message.send.response.*")

onSendResponse.subscribe(block: false) { |delivery_info, properties, payload|
  sendResponse = JSON.parse payload

  # TODO: Handle the Errored case

  if sendResponse["status"] == DispatcherManagerSendResponseDto.Sent
    if delivery_info.routing_key == "message.send.response.email"
      dispatcherManagerEmailSentDto = DispatcherManagerEmailSentDto.new(
        caseNumber: properties[:correlation_id]
      )
      
      dispatcherManagerTopic.publish(
        room: "message.sent.email",
        payload: dispatcherManagerEmailSentDto.to_json
      )
    end  
  end
}

onPlaceMessage = dispatcherManagerTopic.createRoom(name: "message.place.request.*")

onPlaceMessage.subscribe { |delivery_info, properties, payload|
  puts " [x] Received #{payload}"

  placeRequest = JSON.parse payload

  if delivery_info.routing_key == "message.place.request.email"
    dispatcherManagerEmailSendRequestDto = DispatcherManagerEmailSendRequestDto.new(
      from: placeRequest["from"],
      to: placeRequest["to"],
      title: placeRequest["title"],
      body: placeRequest["body"]
    )

    dispatcherManagerTopic.publish(
      room: "message.send.request.email",
      payload: dispatcherManagerEmailSendRequestDto.to_json,
      correlationId: placeRequest["caseNumber"],
      replyTo: "message.send.response.email"
    )
  end

  dispatcherManagerPlaceResponseDto = DispatcherManagerPlaceResponseDto.new(
    status: DispatcherManagerPlaceResponseDto.Placed
  )

  dispatcherManagerTopic.publish(
    room: properties.reply_to, 
    payload: dispatcherManagerPlaceResponseDto.to_json, 
    correlationId: properties.correlation_id
  )
}