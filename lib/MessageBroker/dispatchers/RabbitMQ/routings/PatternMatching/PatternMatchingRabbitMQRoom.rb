require_relative '../BaseRabbitMQRoom'

class PatternMatchingRabbitMQRoom < BaseRabbitMQRoom
  def initialize name:, channel:, exchange:
    queue = channel.queue(name, :auto_delete => true).bind(exchange, :routing_key => name)

    super(queue: queue)
  end
end