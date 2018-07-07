require_relative '../BaseRabbitMQTopic'
require_relative './ExplicitRabbitMQRoom'

class ExplicitRabbitMQTopic < BaseRabbitMQTopic
  def initialize name:, channel:
    super()

    @channel = channel
    @exchange = @channel.direct(name)
  end 

  def createRoom name:
    room = ExplicitRabbitMQRoom.new(
      name: name,
      channel: @channel,
      exchange: @exchange
    )
    
    addRoom(room: room)

    return room
  end

  def publish room:, payload:
    @exchange.publish(payload, :routing_key => room)
  end
end