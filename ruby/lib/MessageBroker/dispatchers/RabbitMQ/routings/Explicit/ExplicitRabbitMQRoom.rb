require_relative '../BaseRabbitMQRoom'

class ExplicitRabbitMQRoom < BaseRabbitMQRoom
  def initialize name:, channel:, exchange:
    queue = channel.queue("").bind(exchange, :routing_key => name)

    super(queue: queue)
  end
end