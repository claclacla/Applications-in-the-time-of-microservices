require_relative "./BaseDto"

class DispatcherManagerSendResponseDto < BaseDto
  @@Sent = "Sent"
  @@Errored = "Errored"

  attr_accessor :uid, :status
  
  def initialize uid: nil, status:
    super(uid: uid)

    @status = status
  end

  def DispatcherManagerSendResponseDto.Sent
    return @@Sent
  end

  def DispatcherManagerSendResponseDto.Errored
    return @@Errored
  end

  def as_json(options={})
    {
      :uid => @uid,
      :status => @status
    }
  end
end