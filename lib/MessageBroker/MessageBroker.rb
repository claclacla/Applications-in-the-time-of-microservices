require_relative 'errors/MessageBrokerConnectionRefused'

class MessageBroker
  def initialize dispatcher:
    @CONNECTION_RETRIES = 10
    @CONNECTION_INTERVAL = 2
    @channels = Hash.new

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

  # TODO: Add a begin/rescue

  def createChannel name:
    @dispatcher.createChannel(name: name)
  end  
end