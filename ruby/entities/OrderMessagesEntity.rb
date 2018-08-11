require_relative './BaseEntity'

# TODO: Add parameters verification

class OrderMessagesEntity < BaseEntity
  attr_accessor :email
  
  def initialize uid: nil
    super(uid: uid)

    @email = []
  end

  def as_json(options={})
    {
      :uid => @uid,
      :email => @email
    }
  end
end