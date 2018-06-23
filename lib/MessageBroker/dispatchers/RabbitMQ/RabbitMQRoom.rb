require_relative '../IRoom'

class RabbitMQRoom
  def initialize name:, channel:, exchange:
    @name = name
    @channel = channel
    @exchange = exchange

    # TODO: the following code stands for Routing.Wide only

    @queue = channel.queue(name, :auto_delete => true).bind(exchange)
  end

  def subscribe
    begin
      @queue.subscribe(block: true) do |_delivery_info, properties, payload|
        yield properties, payload
      end
    rescue Interrupt => _
      
    end
  end

  implements IRoom
end