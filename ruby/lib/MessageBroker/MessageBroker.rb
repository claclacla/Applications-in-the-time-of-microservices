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

  def createTopic name:, routing:
    topic = @dispatcher.createTopic(name: name, routing: routing)

    return topic
  end  
end