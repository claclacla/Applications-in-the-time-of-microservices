require_relative 'errors/MessageBrokerConnectionRefused'

class MessageBroker
  def initialize dispatcher:
    @CONNECTION_RETRIES = 10
    @CONNECTION_INTERVAL = 2
    @routes = Hash.new

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

  def createRoute name:
    route = @dispatcher.createRoute(name: name)
    @routes[name] = route

    return route
  end  
end