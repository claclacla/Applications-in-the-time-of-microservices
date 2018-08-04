require_relative '../lib/UID/UID'
require_relative './IEntity'

class BaseEntity
  def initialize uid: nil
    if uid.nil?
      uid = UID.create
    end
    
    @uid = uid
  end

  def as_json

  end

  def to_json(*options)
    as_json(*options).to_json(*options)
  end

  implements IEntity
end
