require 'bunny'

require_relative '../IDispatcher'
require_relative '../../errors/DispatcherConnectionRefused'
require_relative './topics/RabbitMQTopic'

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
    topic = RabbitMQTopic.new(name: name, channel: @channel, routing: routing)
    @topics.push(topic)

    return topic
  end  

  implements IDispatcher
end