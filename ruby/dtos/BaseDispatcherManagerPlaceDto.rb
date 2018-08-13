require "securerandom"

require_relative './BaseDto'

# TODO: Add parameters verification

class BaseDispatcherManagerPlaceDto < BaseDto 
  attr_accessor :uid
  attr_reader :caseNumber

  def initialize uid: nil
    super(uid: uid)

    @caseNumber = SecureRandom.random_number(36**12).to_s(36).rjust(16, "0")
  end

  def as_json(options={})
    {
      :uid => @uid,
      :caseNumber => @caseNumber
    }
  end
end