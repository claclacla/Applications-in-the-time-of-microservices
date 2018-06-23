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

topic = messageBroker.createTopic(name: "order", routing: Routing.Wide)
room = topic.createRoom(name: "place")

#room.subscribe { |properties, payload|
#   puts " [x] Received #{payload}"
#}

# orderPlaceChannel = messageBroker.createChannel(name: "order.place") 
# orderPlaceChannel.subscribe { |properties, payload|
#   puts " [x] Received #{payload}"

#   orderPlacedChannel = messageBroker.createChannel(name: "order.placed") 
#   orderPlacedChannel.publish(body: "New order placed")
# }