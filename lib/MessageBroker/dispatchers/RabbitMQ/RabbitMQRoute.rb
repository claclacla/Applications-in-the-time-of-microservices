require_relative '../IRoute'

class RabbitMQRoute

  # TODO: Add a begin/rescue

  def initialize channel:, name:
    @channel = channel
    @queue = channel.queue(name)
  end

  # TODO: Handle the Interrupt error

  def subscribe
    begin
      puts "Subscribing..."
      @queue.subscribe(block: true) do |_delivery_info, _properties, body|
        yield body
      end
    rescue Interrupt => _

    end
  end

  def publish body:
    puts "Publishing..." 
    @channel.default_exchange.publish(body, routing_key: @queue.name)
  end

  implements IRoute
end  