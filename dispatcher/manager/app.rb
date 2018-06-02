require_relative '../../lib/MessageBroker/MessageBroker'
require_relative '../../lib/MessageBroker/dispatchers/RabbitMQ/RabbitMQDispatcher'

dispatcher = RabbitMQDispatcher.new(host: "rabbitmq")
messageBroker = MessageBroker.new(dispatcher: dispatcher)

begin
  messageBroker.connect
rescue MessageBrokerConnectionRefused
  abort "RabbitMQ connection refused"
end  

route = messageBroker.createRoute(name: "dispatcher") 

route.subscribe { |payload|
  puts " [x] Received #{payload}"
}
# begin
#   puts ' [*] Waiting for messages. To exit press CTRL+C'
#   queue.subscribe(block: true) do |_delivery_info, _properties, body|
#     puts " [x] Received #{body}"
#   end
# rescue Interrupt => _
#   puts "interruption"
#   connection.close
#   exit(0)
# end