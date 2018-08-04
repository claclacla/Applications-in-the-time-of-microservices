require_relative "./BaseDataProvider"
require_relative "../entities/OrderEntity"

class OrderDataProvider < BaseDataProvider
  def initialize repository:
    super(repository: repository)
  end

  # TODO: verify the orderUSer type

  def place orderUserEntity:
    orderNumber = 1

    # TODO: Get max order number

    orderEntity = OrderEntity.new(number: orderNumber, user: orderUserEntity)

    resOrderEntity = @repository.add(orderEntity: orderEntity)

    resOrderEntity
  end
end