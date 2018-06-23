require 'bunny'

require_relative '../ITopic'

class RabbitMQTopic
  def initialize name:, exchange:
    @name = name
    @exchange = exchange
  end  

  def createRoom

  end

  def publish payload:
    @exchange.publish(payload)
  end

  implements ITopic
end