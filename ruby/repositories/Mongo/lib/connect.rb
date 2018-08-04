require "mongo"

# TODO: Add the user and password parameters
# TODO: Add error rescue

def mongoConnect host:, port:, user:, password:, database:
  Mongo::Logger.logger.level = ::Logger::FATAL
  mongo = Mongo::Client.new([ host + ':' + port ], :database => database)

  return mongo
end