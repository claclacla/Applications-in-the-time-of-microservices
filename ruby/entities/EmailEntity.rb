require_relative './BaseEntity'

# TODO: Add parameters verification

class EmailEntity < BaseEntity
  @@RequestSent = "RequestSent"
  @@RequestAccepted = "RequestAccepted"
  
  attr_accessor :uid, :number, :user, :status
  
  def initialize uid: nil, status: @@RequestSent, receipt:
    super(uid: uid)

    @status = status
    @receipt = receipt
  end

  def EmailEntity.RequestSent
    return @@RequestSent
  end

  def EmailEntity.RequestAccepted
    return @@RequestAccepted
  end

  def as_json(options={})
    {
      :status => @status,
      :receipt => @receipt
    }
  end
end