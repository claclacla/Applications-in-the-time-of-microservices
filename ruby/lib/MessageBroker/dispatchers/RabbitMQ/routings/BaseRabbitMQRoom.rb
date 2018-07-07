require_relative '../../IRoom'

class BaseRabbitMQRoom
  def initialize queue:
    @queue = queue
  end

  def subscribe
    begin
      @queue.subscribe(block: true) do |_delivery_info, properties, payload|
        yield properties, payload
      end
    rescue Interrupt => _
      
    end
  end

  implements IRoom
end