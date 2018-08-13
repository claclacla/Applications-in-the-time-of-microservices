require_relative './BaseEntity'

# TODO: Add parameters verification

class EmailEntity < BaseEntity
  @@StatusRequestSent = "RequestSent"
  @@StatusRequestAccepted = "RequestAccepted"
  
  attr_accessor :uid, :number, :user, :status
  
  def initialize uid: nil, status:, receipt:
    super(uid: uid)

    @status = status
    @receipt = receipt
  end

  def EmailEntity.StatusRequestSent
    return @@StatusRequestSent
  end

  def EmailEntity.StatusRequestAccepted
    return @@StatusRequestAccepted
  end

  def as_json(options={})
    {
      :status => @status,
      :receipt => @receipt
    }
  end
end