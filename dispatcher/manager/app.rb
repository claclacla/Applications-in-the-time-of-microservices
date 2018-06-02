require_relative '../../lib/MessageBroker/RabbitMQ/RabbitMQMessageBroker'

messageBroker = RabbitMQMessageBroker.new(host: "rabbitmq")

begin
  messageBroker.connect
rescue MessageBrokerConnectionRefused
  puts "RabbitMQ connection refused"
end  
#messageBroker.createChannel(name: "hello") 
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