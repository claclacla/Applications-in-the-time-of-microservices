require 'bunny'

require_relative '../IDispatcher'
require_relative 'RabbitMQRoute'
require_relative '../../errors/DispatcherConnectionRefused'

class RabbitMQDispatcher
  def initialize host:
    @connection = Bunny.new(host: host) 
  end  

  def connect connectionInterval:, connectionRetries: 
    begin  
      @connection.start
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

  # TODO: Add a begin/rescue

  def createRoute name:
    route = RabbitMQRoute.new(channel: @connection.create_channel, name: name)

    return route
  end  

  implements IDispatcher
end