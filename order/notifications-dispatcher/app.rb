require 'bunny'

puts "Dispatcher manager..."

def main
  begin
    connection = Bunny.new(host: "rabbitmq", automatically_recover: false)
    connection.start

    channel = connection.create_channel
    queue = channel.queue('hello')
    
    channel.default_exchange.publish('Hello World!', routing_key: queue.name)
    puts " [x] Sent 'Hi!'"
    
    connection.close
  rescue
    sleep(1)
    main
  end  
end

main