require 'json'

require_relative "../../../../ruby/lib/printExecutionTime"
require_relative "../../../../ruby/lib/config"

require_relative "../../../../ruby/dtos/DispatcherManagerSendResponseDto"

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
onEmailSendRequest = dispatcherManagerTopic.createRoom(name: "message.send.request.email")

onEmailSendRequest.subscribe { |delivery_info, properties, payload|
  emailSendRequestPayload = JSON.parse payload

  # ...

  # TODO: Send an email using the payload properties:
  #       from, to, title, body

  # ...

  dispatcherManagerSendResponseDto = DispatcherManagerSendResponseDto.new(
    status: DispatcherManagerSendResponseDto.Sent
  )

  dispatcherManagerTopic.publish(
    room: properties.reply_to, 
    payload: dispatcherManagerSendResponseDto.to_json, 
    correlationId: properties.correlation_id
  )
}