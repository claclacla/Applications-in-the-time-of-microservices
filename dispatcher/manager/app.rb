require 'json'
require 'sinatra'

set :bind, '0.0.0.0'

# TODO: This endpoint may have a response with a 201 status
# TODO: Complete the definition of the response object

post '/email' do
  message = JSON.parse request.body.read

  # Dispatcher manager operations

  # ...

  content_type :json
  { :receipt => 'D9r8Gu39r8B2G3ur' }.to_json
end
