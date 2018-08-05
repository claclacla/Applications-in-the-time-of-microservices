require_relative './BaseEntity'

# TODO: Add parameters verification

class OrderUserEntity < BaseEntity
  attr_accessor :uid, :name, :email, :mobile
  
  def initialize uid: nil, name:, email:, mobile:
    super(uid: uid)

    @name = name
    @email = email
    @mobile = mobile
  end

  def as_json(options={})
    {
      :uid => @uid,
      :name => @name,
      :email => @email,
      :mobile => @mobile
    }
  end
end