require 'interface'

IRepository = interface {
  required_methods :add, :update, :getByUid, :get, :remove
}
