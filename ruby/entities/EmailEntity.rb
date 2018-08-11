require_relative './BaseEntity'

# TODO: Add parameters verification

class EmailEntity < BaseEntity
  @@StatusNew = "New"
  
  attr_accessor :uid, :number, :user, :status
  
  def initialize uid: nil, status:, receipt:
    super(uid: uid)

    @status = status
    @receipt = receipt
  end

  def EmailEntity.StatusNew
    return @@StatusNew
  end

  def as_json(options={})
    {
      :status => @status,
      :receipt => @receipt
    }
  end
end