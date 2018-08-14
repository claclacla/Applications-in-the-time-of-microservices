require 'json'

require_relative "../../../ruby/lib/printExecutionTime"
require_relative "../../../ruby/lib/config"

require_relative "../../../ruby/dtos/DispatcherManagerPlaceResponseDto"

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

printExecutionTime

dispatcherManagerTopic = messageBroker.createTopic(name: "dispatcher-manager", routing: Routing.PatternMatching)
onPlaceMessage = dispatcherManagerTopic.createRoom(name: "message.place.request.*")

onPlaceMessage.subscribe { |delivery_info, properties, payload|
  puts " [x] Received #{payload}"

  message = JSON.parse payload

  dispatcherManagerPlaceResponseDto = DispatcherManagerPlaceResponseDto.new(
    status: DispatcherManagerPlaceResponseDto.Placed
  )

  dispatcherManagerTopic.publish(
    room: properties.reply_to, 
    payload: dispatcherManagerPlaceResponseDto.to_json, 
    correlationId: properties.correlation_id
  )
}