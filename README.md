# Applications in the time of microservices

## Break up your application into smaller dockerized microservices

### MessageBroker library

#### Wide rooms topics

```ruby
# Send a message

topic = messageBroker.createTopic(name: "order", routing: Routing.Wide)
topic.publish(payload: "Place a new order")

# Receive a message

topic = messageBroker.createTopic(name: "order", routing: Routing.Wide)
room = topic.createRoom(name: "place")

room.subscribe { |properties, payload|
   puts " [x] Received #{payload}"
}

```

#### Explicit room topics

```ruby
# Send a message

topic = messageBroker.createTopic(name: "order", routing: Routing.Explicit)
topic.publish(room: "place", payload: "Place a new order")

# Receive a message

topic = messageBroker.createTopic(name: "order", routing: Routing.Explicit)
room = topic.createRoom(name: "place")

room.subscribe { |properties, payload|
   puts " [x] Received #{payload}"
}

```

#### Pattern matching room topics

```ruby
# Send a message

topic = messageBroker.createTopic(name: "delivery", routing: Routing.PatternMatching)
topic.publish(room: "sms.customers", payload: "Important news")

# Receive a message

topic = messageBroker.createTopic(name: "delivery", routing: Routing.PatternMatching)
room = topic.createRoom(name: "sms.*")

room.subscribe { |properties, payload|
   puts " [x] Received #{payload}"
}

```

--------------------------------------------------------------------------------

### Prerequisites

What things you need to install the software

```
docker 17+
docker-compose 1.19.0+

```

--------------------------------------------------------------------------------

### Testing

```
#

```

--------------------------------------------------------------------------------

### Development

```
# Change the directory to the docker development 
cd docker/dev

# Create a .env file with your local application folder
echo "APP_FOLDER=/path-to-your-local/app" > .env 

# Run the micro services using docker compose
sudo docker-compose up -d

# Verify the microservices environment placing a new order
curl -X POST localhost:3000/order -d '{"user":{"name":"Simone","email":"info@claclacla.com","mobile":"321987654"}}' --header "Content-Type: application/json"

```

#### Docker services

```
# Order API
Port: 3000

# Order Socket
Port: 3001

```

--------------------------------------------------------------------------------

## Authors

- **Simone Adelchino** - [_claclacla_](https://twitter.com/_claclacla_)

--------------------------------------------------------------------------------

## License

This project is licensed under the MIT License

--------------------------------------------------------------------------------

## Acknowledgments

- [Docker](https://www.docker.com/)