require_relative './BaseEntity'
require_relative "./OrderStatusEntity"

# TODO: Add parameters verification

class OrderEntity < BaseEntity
  attr_accessor :uid, :number, :user, :status
  
  def initialize uid: nil, number:, user:, status: OrderStatusEntity.New
    super(uid: uid)

    @number = number
    @user = user
    @status = status
  end

  def as_json(options={})
    {
      :uid => @uid,
      :number => @number,
      :user => @user,
      :status => @status
    }
  end
end