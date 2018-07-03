require 'bunny'

require_relative '../IDispatcher'
require_relative '../../errors/DispatcherConnectionRefused'
require_relative './routings/Wide/WideRabbitMQTopic'
require_relative './routings/Explicit/ExplicitRabbitMQTopic'
require_relative './routings/PatternMatching/PatternMatchingRabbitMQTopic'

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
    topic = nil

    case routing
    when Routing.Wide
      topic = WideRabbitMQTopic.new(name: name, channel: @channel)
    when Routing.Explicit
      topic = ExplicitRabbitMQTopic.new(name: name, channel: @channel)
    when Routing.PatternMatching
      topic = PatternMatchingRabbitMQTopic.new(name: name, channel: @channel)
    end

    @topics.push(topic)

    return topic
  end  

  implements IDispatcher
end