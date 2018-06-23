require 'bunny'

require_relative '../IDispatcher'
require_relative '../../Routing'
require_relative '../../errors/DispatcherConnectionRefused'
require_relative './RabbitMQTopic'

class RabbitMQDispatcher
  def initialize host:
    @connection = Bunny.new(host: host)
    @channel = nil 
    @topics = []
  end  

  def connect connectionInterval:, connectionRetries: 
    begin  
      @connection.start
      @channel = @connection.create_channel
    rescue Bunny::TCPConnectionFailedForAllHosts
      sleep connectionInterval
      connectionRetries -= 1

      raise DispatcherConnectionRefused if connectionRetries == 0

      connect(
        connectionInterval: connectionInterval, 
        connectionRetries: connectionRetries
      )
    end
  end  

  def createTopic name:, routing:
    exchange = nil    

    case routing
    when Routing.Wide
      exchange = @channel.fanout(name)
    when Routing.Explicit
      exchange = @channel.direct(name)
    when Routing.PatternMatching
      exchange = @channel.topic(name)
    end

    topic = RabbitMQTopic.new(name: name, exchange: exchange)
    @topics.push(topic)

    return topic
  end  

  implements IDispatcher
end