require 'json'

require_relative "../../../../ruby/lib/printExecutionTime"
require_relative "../../../../ruby/lib/config"

require_relative "../../../../ruby/dtos/DispatcherManagerSendResponseDto"

require_relative '../../../../ruby/lib/MessageBroker/MessageBroker'
require_relative '../../../../ruby/lib/MessageBroker/dispatchers/RabbitMQ/RabbitMQDispatcher'
require_relative '../../../../ruby/lib/MessageBroker/Routing'

dispatcher = RabbitMQDispatcher.new(host: config["rabbitmq"]["host"])
messageBroker = MessageBroker.new(dispatcher: dispatcher)

begin
  messageBroker.connect
rescue MessageBrokerConnectionRefused
  abort "RabbitMQ connection refused"
end

printExecutionTime

dispatcherManagerTopic = messageBroker.createTopic(name: "dispatcher-manager", routing: Routing.PatternMatching)
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