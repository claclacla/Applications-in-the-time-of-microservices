require 'bunny'

require_relative '../ITopic'

class RabbitMQTopic
  def initialize name:, exchange:
    @name = name
    @exchange = exchange
  end  

  def createList

  end

  implements ITopic
end