# Applications in the time of microservices

## Break up your application into smaller dockerized microservices

Microservices have redefined the way applications are built.
Software architecture has changed and nowadays based on an environment of many different applications.

Each service is extremely specialized and actually responsible for just one task.

This repository is a dockerized environment of microservices that handles the placement of an order.

The interaction among services is provided by the MessageBroker library.

### MessageBroker library

This library, created for both languages `Javascript` and `Ruby`, is an abstraction layer over `RabbitMQ`. 
It allows the communication among the microservices, providing functionality for publishing and subscribing events.

The microservices interact through topics created with one of three routing types: `Wide`, `Explicit` and `PatternMatching`. 

Each topic may have multiple rooms and, according to the routing type, microservices exchange messages on a different way.

#### Wide topic

Each message published on a wide topic is received by each room connected to it.

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

#### Explicit topic

For this kind of topic a message is published on an specific room using its exact name.
 
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

#### Pattern matching topic

Using a pattern matching routing, a microservice subscribe to a room based on matching between a message routing key and the pattern that was used to create that room.

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

# Open your browser and type the following address
# to connect to the client application
http://localhost:8080

# Verify the microservices environment placing a new order 
# using the button "Insert order"

```

#### Docker services

```
# Order API
Port: 3000

# Client order Socket
Port: 3001

# Client application
Port: 8080

# Vendor order Socket
Port: 3002

# Vendor application
Port: 8081

```

#### MessageBroker topics

Order

* get
* got
* place
* placed
* patch
* patched

Orders

* get
* got

Message

* email.sent

--------------------------------------------------------------------------------

## Authors

- **Simone Adelchino** - [_claclacla_](https://twitter.com/_claclacla_)

--------------------------------------------------------------------------------

## License

This project is licensed under the MIT License

--------------------------------------------------------------------------------

## Acknowledgments

- [Ruby MongoDB driver](https://docs.mongodb.com/ruby-driver/master/ruby-driver-tutorials/)