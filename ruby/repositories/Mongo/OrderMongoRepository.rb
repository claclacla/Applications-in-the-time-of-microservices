require_relative "../../entities/OrderUserEntity"
require_relative "../../entities/OrderEntity"
require_relative "../IRepository"

class OrderMongoRepository
  @@PatchReplace = "replace"
  @@PatchAdd = "add"
  
  def initialize mongo:
    @mongo = mongo 
  end

  def PatchReplace
    return @@PatchReplace
  end

  def PatchAdd
    return @@PatchAdd
  end

  # TODO: Add parameter type verification
  # TODO: Add error rescue

  def add orderEntity:

    dbOrderEntity = { 
      :uid => orderEntity.uid,
      :number => orderEntity.number,
      :user => {
        :name => orderEntity.user.name,
        :email => orderEntity.user.email,
        :mobile => orderEntity.user.mobile
      },
      :status => orderEntity.status,
      :messages => orderEntity.messages
    }

    result = @mongo[:order].insert_one(dbOrderEntity)

    # TODO: Check if result.n == 1

    resOrder = @mongo[:order].find({"uid" => orderEntity.uid}).limit(1).first

    orderUserEntity = OrderUserEntity.new(
      name: resOrder["user"]["name"],
      email: resOrder["user"]["email"],
      mobile: resOrder["user"]["mobile"]
    )

    resOrderEntity = OrderEntity.new(
      uid: resOrder["uid"],
      number: resOrder["number"],
      status: resOrder["status"],
      messages: resOrder["messages"],
      user: orderUserEntity
    )

    return resOrderEntity
  end

  def update query:, orderEntity:

  end

  def patch query:, operation:, patch:
    update = nil

    if operation == @@PatchReplace
      update = { "$set" => patch }
    elsif operation == @@PatchAdd
      update = { "$push" => patch }
    end 
    
    # TODO: Check if update is nil

    resOrder = @mongo[:order].find_one_and_replace(
      query, update, :return_document => :after
    )

    resOrderUserEntity = OrderUserEntity.new(
      name: resOrder["user"]["name"],
      email: resOrder["user"]["email"],
      mobile: resOrder["user"]["mobile"]
    )

    resOrderEntity = OrderEntity.new(
      uid: resOrder["uid"],
      number: resOrder["number"],
      status: resOrder["status"],
      messages: resOrder["messages"],
      user: resOrderUserEntity
    )

    return resOrderEntity
  end

  # TODO: Add uid verification
  # TODO: Add not found rescue

  def getByUid uid:
    resOrder = @mongo[:order].find({"uid" => uid}).limit(1).first

    resOrderUserEntity = OrderUserEntity.new(
      name: resOrder["user"]["name"],
      email: resOrder["user"]["email"],
      mobile: resOrder["user"]["mobile"]
    )

    resOrderEntity = OrderEntity.new(
      uid: resOrder["uid"],
      number: resOrder["number"],
      status: resOrder["status"],
      messages: resOrder["messages"],
      user: resOrderUserEntity
    )

    return resOrderEntity
  end

  def mapGetFilters filters:
    getFilters = []

    if filters["sort"]
      getFilters.push({"$sort" => filters["sort"]})
    end

    if filters["skip"]
      getFilters.push({"$skip" => filters["skip"]})
    end

    if filters["limit"]
      getFilters.push({"$limit" => filters["limit"]})
    end

    getFilters
  end

  # TODO: Add filters(skip, limit, sort)

  def get match: nil, filters: nil
    resOrderEntities = []
    query = []

    if match != nil
      query.push({"$match" => match})
    end

    query.push({"$project" => {
      "uid" => 1,
      "number" => 1,
      "user" => 1,
      "status" => 1,
      "messages" => 1
    }})

    if !filters.nil?
      getFilters = mapGetFilters(filters: filters)

      if !getFilters.empty?
        query.concat(getFilters)
      end
    end

    @mongo[:order].aggregate(query).each do |resOrder|
      resOrderUserEntity = OrderUserEntity.new(
        name: resOrder["user"]["name"],
        email: resOrder["user"]["email"],
        mobile: resOrder["user"]["mobile"]
      )
  
      resOrderEntity = OrderEntity.new(
        uid: resOrder["uid"],
        number: resOrder["number"],
        status: resOrder["status"],
        messages: resOrder["messages"],
        user: resOrderUserEntity
      )
  
      resOrderEntities.push resOrderEntity
    end

    return resOrderEntities
  end

  def remove filter:

  end

  implements IRepository
end