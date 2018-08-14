require_relative './BaseEntity'
require_relative "./OrderStatusEntity"

# TODO: Add parameters verification

class OrderEntity < BaseEntity
  attr_accessor :uid, :number, :user, :status, :messages
  
  def initialize uid: nil, number:, user:, status: OrderStatusEntity.New, messages: { "email" => [ ] }
    super(uid: uid)

    @number = number
    @user = user
    @status = status
    @messages = messages
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