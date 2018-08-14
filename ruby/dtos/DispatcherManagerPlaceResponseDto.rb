require_relative "./BaseDto"

class DispatcherManagerPlaceResponseDto < BaseDto
  @@Placed = "Placed"
  @@Errored = "Errored"

  attr_accessor :uid, :status
  
  def initialize uid: nil, status:
    super(uid: uid)

    @status = status
  end

  def DispatcherManagerPlaceResponseDto.Placed
    return @@Placed
  end

  def DispatcherManagerPlaceResponseDto.Errored
    return @@Errored
  end

  def as_json(options={})
    {
      :uid => @uid,
      :status => @status
    }
  end
end