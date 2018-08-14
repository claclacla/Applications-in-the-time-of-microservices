require_relative "./BaseDataProvider"
require_relative "../entities/OrderEntity"
require_relative "../entities/EmailEntity"

class OrderDataProvider < BaseDataProvider
  def initialize repository:
    super(repository: repository)

    @@PatchReplace = repository.PatchReplace
    @@PatchAdd = repository.PatchAdd
  end

  def OrderDataProvider.PatchReplace
    return @@PatchReplace
  end

  def OrderDataProvider.PatchAdd
    return @@PatchAdd
  end

  # TODO: verify the orderUser type

  def place orderUserEntity:
    orderNumber = 1

    resOrderEntities = @repository.get(filters: {
      "sort" => {"number" => -1},
      "limit" => 1
    })

    if !resOrderEntities.empty?
      resOrderEntity = resOrderEntities[0]
      orderNumber = resOrderEntity.number + 1
    end

    orderEntity = OrderEntity.new(number: orderNumber, user: orderUserEntity)

    resOrderEntity = @repository.add(orderEntity: orderEntity)

    resOrderEntity
  end

  def getByUid uid:
    @repository.getByUid(uid: uid)
  end

  # TODO: Add match and filters

  def get
    @repository.get()
  end

  def patch uid:, operation:, patch:
    @repository.patch(query: {"uid" => uid}, operation: operation, patch: patch)
  end

  # Messages

  def attachEmail uid:, caseNumber:
    patch = { 
      "messages.email" => {
        "status" => EmailEntity.RequestSent,
        "caseNumber" => caseNumber
      }
    }

    @repository.patch(query: {"uid" => uid}, operation: @repository.PatchAdd, patch: patch)
  end

  def setEmailStatus caseNumber:, status:

  end
end