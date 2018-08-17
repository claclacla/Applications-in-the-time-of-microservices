require_relative './BaseEntity'

# TODO: Add parameters verification

class EmailEntity < BaseEntity
  @@RequestSent = "RequestSent"
  @@RequestAccepted = "RequestAccepted"
  @@Sent = "Sent"
  
  attr_accessor :uid, :status, :caseNumber
  
  def initialize uid: nil, status: @@RequestSent, caseNumber:
    super(uid: uid)

    @status = status
    @caseNumber = caseNumber
  end

  def EmailEntity.RequestSent
    return @@RequestSent
  end

  def EmailEntity.RequestAccepted
    return @@RequestAccepted
  end

  def EmailEntity.Sent
    return @@Sent
  end

  def as_json(options={})
    {
      :status => @status,
      :caseNumber => @caseNumber
    }
  end
end