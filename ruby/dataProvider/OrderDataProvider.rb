require_relative "./BaseDataProvider"
require_relative "../entities/OrderEntity"

class OrderDataProvider < BaseDataProvider
  def initialize repository:
    super(repository: repository)
  end

  # TODO: verify the orderUSer type

  def place orderUserEntity:
    orderNumber = 1

    resOrderEntities = @repository.get(filters: {
      "sort" => {"number" => -1},
      "limit" => 1
    })
    puts resOrderEntities.length

    if !resOrderEntities.empty?
      resOrderEntity = resOrderEntities[0]
      orderNumber = resOrderEntity.number + 1
    end

    orderEntity = OrderEntity.new(number: orderNumber, user: orderUserEntity)

    resOrderEntity = @repository.add(orderEntity: orderEntity)

    resOrderEntity
  end
end