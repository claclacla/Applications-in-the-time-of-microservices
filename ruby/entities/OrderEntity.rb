require_relative './BaseEntity'

# TODO: Add parameters verification

class OrderEntity < BaseEntity
  attr_accessor :uid, :number, :user
  
  def initialize uid: nil, number:, user:
    super(uid: uid)

    @number = number
    @user = user
  end

  def as_json(options={})
    {
      :number => @number,
      :user => @user
    }
  end
end