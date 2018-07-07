require_relative '../BaseRabbitMQRoom'

class WideRabbitMQRoom < BaseRabbitMQRoom
  def initialize name:, channel:, exchange:
    queue = channel.queue(name, :auto_delete => true).bind(exchange)

    super(queue: queue)
  end
end