require_relative '../BaseRabbitMQTopic'
require_relative './PatternMatchingRabbitMQRoom'

class PatternMatchingRabbitMQTopic < BaseRabbitMQTopic
  def initialize name:, channel:
    super()

    @channel = channel
    @exchange = @channel.topic(name)
  end  

  def createRoom name:
    room = PatternMatchingRabbitMQRoom.new(
      name: name,
      channel: @channel,
      exchange: @exchange
    )
    
    addRoom(room: room)

    return room
  end

  def publish room:, payload:, correlationId: nil, replyTo: nil
    @exchange.publish(
      payload, 
      :routing_key => room, 
      :correlation_id => correlationId,
      :replyTo => replyTo
    )
  end
end