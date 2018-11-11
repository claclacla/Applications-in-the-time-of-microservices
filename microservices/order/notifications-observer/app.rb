require 'json'

require_relative "../../../ruby/lib/printExecutionTime"
require_relative "../../../ruby/lib/config"

require_relative "../../../ruby/repositories/Mongo/lib/connect"
require_relative "../../../ruby/repositories/Mongo/OrderMongoRepository"
require_relative "../../../ruby/dataProvider/OrderDataProvider"
require_relative "../../../ruby/entities/EmailEntity"

require 'postcard_rb'
require 'postcard_rb/errors/PostcardConnectionRefused'
require 'postcard_rb/dispatchers/RabbitMQ/RabbitMQDispatcher'
require 'postcard_rb/Routing'

dispatcher = RabbitMQDispatcher.new(host: config["rabbitmq"]["host"])
postcardRB = PostcardRB.new(dispatcher: dispatcher)

begin
  postcardRB.connect
rescue PostcardConnectionRefused
  abort "RabbitMQ connection refused"
end

mongo = mongoConnect(
  host: config["mongodb"]["host"], 
  port: config["mongodb"]["port"], 
  user: config["mongodb"]["username"], 
  password: config["mongodb"]["password"], 
  database: config["mongodb"]["database"]
)

printExecutionTime

orderMongoRepository = OrderMongoRepository.new(mongo: mongo)
orderDataProvider = OrderDataProvider.new(repository: orderMongoRepository)

dispatcherManagerTopic = postcardRB.createTopic(name: "dispatcher-manager", routing: Routing.PatternMatching)

onEmailSent = dispatcherManagerTopic.createRoom(name: "message.sent.email")

onEmailSent.subscribe { |delivery_info, properties, payload|
  emailSentResponse = JSON.parse payload

  orderDataProvider.setEmailStatus(
    caseNumber: emailSentResponse["caseNumber"], 
    status: EmailEntity.Sent
  )
}