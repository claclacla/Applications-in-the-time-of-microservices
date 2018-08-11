require_relative './BaseEntity'
require_relative "./OrderStatusEntity"
require_relative "./OrderMessagesEntity"

# TODO: Add parameters verification

class OrderEntity < BaseEntity
  attr_accessor :uid, :number, :user, :status
  
  def initialize uid: nil, number:, user:, status: OrderStatusEntity.New
    super(uid: uid)

    @number = number
    @user = user
    @status = status
    @messages = OrderMessagesEntity.new
  end

  def as_json(options={})
    {
      :uid => @uid,
      :number => @number,
      :user => @user,
      :status => @status,
      :messages => @messages
    }
  end
end