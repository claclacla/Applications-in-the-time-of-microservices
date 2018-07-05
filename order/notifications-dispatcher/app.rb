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

orderTopic = messageBroker.createTopic(name: "order", routing: Routing.Explicit)
orderStatusPlaced = orderTopic.createRoom(name: "status.placed")

dispatcherTopic = messageBroker.createTopic(name: "dispatcher", routing: Routing.PatternMatching)

orderStatusPlaced.subscribe { |properties, payload|
  puts " [x] Received #{payload}"

  dispatcherTopic.publish(room: "send.email", payload: "Send a new email")
}

# orderPlacedChannel = messageBroker.createChannel(name: "order.placed") 
# orderPlacedChannel.subscribe { |properties, payload|
#   puts " [x] Received #{payload}"

#   dispatcherSendEmailChannel = messageBroker.createChannel(name: "dispatcher.send.email") 
#   dispatcherSendEmailChannel.publish(body: "Send a new email")
# }