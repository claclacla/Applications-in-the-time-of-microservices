require_relative '../BaseRabbitMQTopic'
require_relative './WideRabbitMQRoom'

class WideRabbitMQTopic < BaseRabbitMQTopic
  def initialize name:, channel:
    super()

    @channel = channel
    @exchange = @channel.fanout(name)
  end  

  def createRoom name:
    room = WideRabbitMQRoom.new(
      name: name,
      channel: @channel,
      exchange: @exchange
    )
    
    addRoom(room: room)

    return room
  end

  def publish payload:, correlationId: nil, replyTo: nil
    @exchange.publish(
      payload, 
      :correlation_id => correlationId,
      :reply_to => replyTo
    )
  end
end