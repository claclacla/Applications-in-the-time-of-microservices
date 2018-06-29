require_relative '../../IRoom'
require_relative '../../../Routing'

class RabbitMQRoom
  def initialize name:, routing:, channel:, exchange:
    @name = name
    @routing = routing
    @channel = channel
    @exchange = exchange      

    case @routing
    when Routing.Wide
      @queue = @channel.queue(@name, :auto_delete => true).bind(@exchange)  
    when Routing.Explicit
      @queue = @channel.queue(@name, :auto_delete => true).bind(@exchange, :routing_key => @name)
    when Routing.PatternMatching
      @queue = @channel.queue(@name, :auto_delete => true).bind(@exchange, :routing_key => @name)
    end  
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