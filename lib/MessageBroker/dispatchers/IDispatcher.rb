require 'interface'

IDispatcher = interface {
  required_methods :connect, :createChannel
}