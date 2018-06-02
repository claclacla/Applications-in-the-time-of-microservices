require 'interface'

IChannel = interface {
  required_methods :subscribe, :publish
}