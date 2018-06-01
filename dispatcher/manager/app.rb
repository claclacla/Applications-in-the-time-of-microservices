require 'bunny'

puts "Dispatcher manager..."

def main
  begin
    connection = Bunny.new(:host => "rabbitmq", :automatically_recover => false)
    connection.start

    channel = connection.create_channel
    queue = channel.queue('hello')

    begin
      puts ' [*] Waiting for messages. To exit press CTRL+C'
      queue.subscribe(block: true) do |_delivery_info, _properties, body|
        puts " [x] Received #{body}"
      end
    rescue Interrupt => _
      puts "interruption"
      connection.close

      exit(0)
    end
  rescue
    sleep(1)
    main
  end  
end

main