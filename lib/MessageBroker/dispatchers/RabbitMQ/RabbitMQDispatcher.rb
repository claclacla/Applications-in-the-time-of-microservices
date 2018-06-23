require 'bunny'

require_relative '../IDispatcher'
require_relative '../../Routing'
require_relative '../../errors/DispatcherConnectionRefused'

class RabbitMQDispatcher
  def initialize host:
    @connection = Bunny.new(host: host)
    @channel = nil 
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
    case routing
    when Routing.Wide
      return @channel.fanout(name)
    when Routing.Explicit
      return @channel.direct(name)
    when Routing.PatternMatching
      return @channel.topic(name)
    end  
  end  

  implements IDispatcher
end