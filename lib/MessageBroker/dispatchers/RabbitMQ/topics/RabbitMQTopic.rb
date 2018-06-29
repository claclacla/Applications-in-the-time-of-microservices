require_relative '../../ITopic'
require_relative '../../../Routing'
require_relative '../rooms/RabbitMQRoom'

class RabbitMQTopic
  def initialize name:, channel:, routing:
    @name = name
    @channel = channel
    @routing = routing
    @exchange = nil
    
    @rooms = []

    case @routing
    when Routing.Wide
      @exchange = channel.fanout(name)
    when Routing.Explicit
      @exchange = channel.direct(name)
    when Routing.PatternMatching
      @exchange = channel.topic(name)
    end
  end  

  def createRoom name:
    room = RabbitMQRoom.new(
      name: name, 
      routing: @routing, 
      channel: @channel, 
      exchange: @exchange
    )
    @rooms.append(room)

    return room
  end

  def publish room: nil, payload:
    case @routing
    when Routing.Wide
      @exchange.publish(payload)
    when Routing.Explicit
      @exchange.publish(payload, :routing_key => room)
    when Routing.PatternMatching
      @exchange.publish(payload, :routing_key => room)
    end
  end

  implements ITopic
end