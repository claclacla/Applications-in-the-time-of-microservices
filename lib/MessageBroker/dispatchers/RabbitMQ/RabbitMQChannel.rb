require_relative '../IChannel'

class RabbitMQChannel

  # TODO: Add a begin/rescue

  def initialize connection_channel:, name:
    @connection_channel = connection_channel
    @queue = connection_channel.queue(name)
  end

  # TODO: Handle the Interrupt error

  def subscribe
    begin
      @queue.subscribe(block: true) do |_delivery_info, properties, payload|
        yield properties, payload
      end
    rescue Interrupt => _
      
    end
  end

  def publish body:
    @connection_channel.default_exchange.publish(body, routing_key: @queue.name)
  end

  implements IChannel
end  