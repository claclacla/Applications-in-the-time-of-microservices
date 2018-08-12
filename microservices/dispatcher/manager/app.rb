require 'json'

require_relative "../../../ruby/lib/printExecutionTime"
require_relative "../../../ruby/lib/config"

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

dispatcherManagerTopic = messageBroker.createTopic(name: "dispatcher-manager", routing: Routing.Explicit)
onPlaceEmail = dispatcherManagerTopic.createRoom(name: "email.place")

onPlaceEmail.subscribe { |delivery_info, properties, payload|
  puts " [x] Received #{payload}"

  message = JSON.parse payload

  # TODO: Define the object for this response

  dispatchedData = {
    "receipt" => "oij45tkj8d4G-Wed5"
  }

  dispatcherManagerTopic.publish(
    room: "email.placed", 
    payload: dispatchedData.to_json, 
    correlationId: properties.correlation_id
  )
}