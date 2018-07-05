require_relative '../../lib/MessageBroker/MessageBroker'
require_relative '../../lib/MessageBroker/dispatchers/RabbitMQ/RabbitMQDispatcher'
require_relative '../../lib/MessageBroker/Routing'

dispatcher = RabbitMQDispatcher.new(host: "rabbitmq")
messageBroker = MessageBroker.new(dispatcher: dispatcher)

begin
  messageBroker.connect
rescue MessageBrokerConnectionRefused
  abort "RabbitMQ connection refused"
end

topic = messageBroker.createTopic(name: "dispatcher", routing: Routing.PatternMatching)
dispatcherSend = topic.createRoom(name: "send.*")

dispatcherSend.subscribe { |properties, payload|
  puts " [x] Received #{payload}"
}

# channel = messageBroker.createChannel(name: "dispatcher.send.email") 
# channel.subscribe { |properties, payload|
#   puts " [x] Received #{payload}" 
# }
