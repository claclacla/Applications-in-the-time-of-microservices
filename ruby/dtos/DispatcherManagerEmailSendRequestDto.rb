require_relative './BaseDispatcherManagerPlaceRequestDto'

# TODO: Add parameters verification

class DispatcherManagerEmailSendRequestDto < BaseDispatcherManagerPlaceRequestDto
  attr_accessor :uid, :from, :to, :title, :body
  
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
      :from => @from,
      :to => @to,
      :title => @title,
      :body => @body
    }
  end
end