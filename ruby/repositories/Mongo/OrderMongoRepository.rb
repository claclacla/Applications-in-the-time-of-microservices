require_relative "../../entities/OrderUserEntity"
require_relative "../../entities/OrderEntity"
require_relative "../IRepository"

class OrderMongoRepository
  def initialize mongo:
    @mongo = mongo 

    @@PatchReplace = "replace"
  end

  def PatchReplace
    return @@PatchReplace
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
      :status => orderEntity.status 
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
      user: orderUserEntity
    )

    return resOrderEntity
  end

  def update query:, orderEntity:
=begin
    dbOrderEntity = { 
      "uid" => orderEntity.uid,
      "season" => orderEntity.season,
      "code" => orderEntity.code,
      "col_style_fabric_string" => orderEntity.col_style_fabric_string,
      "user_zona" => orderEntity.user_zona,
      "amount" => orderEntity.amount,
      "warehouse" => orderEntity.warehouse,
      "sockets" => orderEntity.sockets
    }

    if !orderEntity.code29.nil?  
      dbOrderEntity["code29"] = orderEntity.code29
    end

    resOrder = @mongo[:order].find_one_and_replace(
      query, dbOrderEntity)

    resOrderEntity = OrderEntity.new(
      uid: resOrder["uid"],
      season: resOrder["season"],
      code: resOrder["code"],
      col_style_fabric_string: resOrder["col_style_fabric_string"],
      user_zona: resOrder["user_zona"],
      warehouse: resOrder["warehouse"],
      amount: resOrder["amount"],
      sockets: resOrder["sockets"]
    )

    if !resOrder["code29"].nil?
      resOrderEntity.code29 = resOrder["code29"]
    end

    return resOrderEntity
=end
  end

  def patch query:, operation:, patch:
    update = nil

    if operation == OrderMongoRepository.PatchReplace
      update = { "$set" => patch }
    end  

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
      "status" => 1
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
        user: resOrderUserEntity
      )
  
      resOrderEntities.push resOrderEntity
    end

    return resOrderEntities
  end

  def remove filter:
=begin
    @mongo[:order].find(filter).delete_many
=end
  end

  implements IRepository
end