require_relative '../../ITopic'

class BaseRabbitMQTopic
  def initialize 
    @rooms = []
  end

  def addRoom room:
    @rooms.append(room)
  end

  def createRoom; end
  def publish; end

  implements ITopic

  private :addRoom
end