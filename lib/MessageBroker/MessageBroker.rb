require_relative 'errors/MessageBrokerConnectionRefused'

class MessageBroker
  def initialize dispatcher:
    @CONNECTION_RETRIES = 10
    @CONNECTION_INTERVAL = 2

    @dispatcher = dispatcher 
  end   

  def connect
    begin
      @dispatcher.connect(
        connectionInterval: @CONNECTION_INTERVAL, 
        connectionRetries: @CONNECTION_RETRIES
      )
    rescue DispatcherConnectionRefused
      raise MessageBrokerConnectionRefused
    end  
  end

  # def createChannel name:
  #   channel = @connection.create_channel
  #   queue = channel.queue(name)

  #   @channels[name] = { channel: channel, queue: queue }
  # end  
end