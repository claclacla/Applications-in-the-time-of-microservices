require_relative './BaseDto'

# TODO: Add parameters verification

class DispatcherManagerEmailSentDto < BaseDto 
  attr_accessor :uid, :caseNumber

  def initialize uid: nil, caseNumber:
    super(uid: uid)

    @caseNumber = caseNumber
  end

  def as_json(options={})
    {
      :uid => @uid,
      :caseNumber => @caseNumber
    }
  end
end