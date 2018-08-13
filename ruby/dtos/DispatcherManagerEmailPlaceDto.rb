require_relative './BaseDispatcherManagerPlaceDto'

# TODO: Add parameters verification

class DispatcherManagerEmailPlaceDto < BaseDispatcherManagerPlaceDto
  attr_accessor :uid, :from, :to, :title, :body
  attr_reader :caseNumber
  
  def initialize uid: nil, from:, to:, title:, body:
    super(uid: uid)

    @from = from
    @to = to
    @title = title
    @body = body
  end

  def as_json(options={})
    {
      :uid => @uid,
      :caseNumber => @caseNumber,
      :from => @from,
      :to => @to,
      :title => @title,
      :body => @body
    }
  end
end