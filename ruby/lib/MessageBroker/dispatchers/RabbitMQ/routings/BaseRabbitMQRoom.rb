require_relative '../../IRoom'

class BaseRabbitMQRoom
  def initialize queue:
    @queue = queue
  end

  def subscribe block: true
    begin
      @queue.subscribe(block: block) do |delivery_info, properties, payload|
        puts "subscribe 1"
        yield delivery_info, properties, payload
      end
    rescue Interrupt => _
    
    end
  end

  implements IRoom
end