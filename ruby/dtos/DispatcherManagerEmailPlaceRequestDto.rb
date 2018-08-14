require_relative './BaseDispatcherManagerPlaceRequestDto'

# TODO: Add parameters verification

class DispatcherManagerEmailPlaceRequestDto < BaseDispatcherManagerPlaceRequestDto
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