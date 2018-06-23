require_relative '../IRoom'

class RabbitMQRoom
  def initialize name:, channel:, exchange:
    @name = name
    @channel = channel
    @exchange = exchange

    @queue = channel.queue(name, :auto_delete => true).bind(exchange)
  end

  def subscribe

  end

  implements IRoom
end