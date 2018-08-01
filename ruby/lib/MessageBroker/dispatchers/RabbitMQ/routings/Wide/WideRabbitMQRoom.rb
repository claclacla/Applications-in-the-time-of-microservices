require_relative '../BaseRabbitMQRoom'

class WideRabbitMQRoom < BaseRabbitMQRoom
  def initialize name:, channel:, exchange:
    queue = channel.queue("").bind(exchange)

    super(queue: queue)
  end
end