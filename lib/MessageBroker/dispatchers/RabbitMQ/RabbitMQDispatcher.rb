require 'bunny'

require_relative '../IDispatcher'
require_relative '../../errors/DispatcherConnectionRefused'

class RabbitMQDispatcher
  def initialize host:
    @channels = Hash.new

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

  def createChannel name:
    channel = @connection.create_channel
    queue = channel.queue(name)

    @channels[name] = { channel: channel, queue: queue }
  end  

  implements IDispatcher
end