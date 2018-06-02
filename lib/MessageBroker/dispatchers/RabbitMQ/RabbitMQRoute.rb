require_relative '../IRoute'

class RabbitMQRoute

  # TODO: Add a begin/rescue

  def initialize channel:, name:
    @channel = channel
    @queue = channel.queue(name)
  end

  def subscribe
    yield "HI"
  end

  implements IRoute
end  