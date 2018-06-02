require 'bunny'

require_relative '../MessageBrokerConnectionRefused'

class RabbitMQMessageBroker
  def initialize host:
    @CONNECTION_RETRIES = 10
    @CONNECTION_INTERVAL = 1

    @channels = Hash.new

    @connection = Bunny.new(host: host) 
  end  

  private def makeConnection connectionInterval:, connectionRetries: 
    begin  
      @connection.start
    rescue Bunny::TCPConnectionFailedForAllHosts
      sleep connectionInterval
      connectionRetries -= 1

      raise MessageBrokerConnectionRefused if connectionRetries == 0

      makeConnection(
        connectionInterval: connectionInterval, 
        connectionRetries: connectionRetries
      )
    end
  end  

  def connect
    makeConnection(
      connectionInterval: @CONNECTION_INTERVAL, 
      connectionRetries: @CONNECTION_RETRIES
    )
  end

  def createChannel name:
    channel = @connection.create_channel
    queue = channel.queue(name)

    @channels[name] = { channel: channel, queue: queue }
  end  
end