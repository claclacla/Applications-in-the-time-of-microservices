require 'bunny'

require_relative '../ITopic'
require_relative '../../Routing'

class RabbitMQTopic
  def initialize name:, channel:, routing:
    @name = name
    @channel = channel
    @exchange = nil  

    case routing
    when Routing.Wide
      @exchange = channel.fanout(name)
    when Routing.Explicit
      @exchange = channel.direct(name)
    when Routing.PatternMatching
      @exchange = channel.topic(name)
    end
  end  

  def createRoom
    #q = ch.queue("", :auto_delete => true).bind(x)
  end

  def publish payload:
    @exchange.publish(payload)
  end

  implements ITopic
end