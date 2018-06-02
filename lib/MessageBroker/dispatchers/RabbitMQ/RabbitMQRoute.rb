require_relative '../IRoute'

class RabbitMQRoute

  # TODO: Add a begin/rescue

  def initialize channel:, name:
    @channel = channel
    @queue = channel.queue(name)
  end

  # TODO: Handle the Interrupt error

  def subscribe
    begin
      @queue.subscribe(block: true) do |_delivery_info, _properties, body|
        yield body
      end
    rescue Interrupt => _

    end
  end

  implements IRoute
end  