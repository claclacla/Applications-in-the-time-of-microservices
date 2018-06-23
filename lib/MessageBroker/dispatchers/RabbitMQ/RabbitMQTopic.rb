require_relative '../ITopic'
require_relative '../../Routing'
require_relative './RabbitMQRoom'

class RabbitMQTopic
  def initialize name:, channel:, routing:
    @name = name
    @channel = channel
    @exchange = nil
    
    @rooms = []

    case routing
    when Routing.Wide
      @exchange = channel.fanout(name)
    when Routing.Explicit
      @exchange = channel.direct(name)
    when Routing.PatternMatching
      @exchange = channel.topic(name)
    end
  end  

  def createRoom name:
    room = RabbitMQRoom.new(name: name, channel: @channel, exchange: @exchange)
    @rooms.append(room)

    return room
  end

  def publish payload:
    @exchange.publish(payload)
  end

  implements ITopic
end