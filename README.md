# Applications in the time of microservices

## Break up your application into smaller dockerized microservices

Microservices have redefined the way applications are built. Software development has changed and nowadays applications are based on an environment of many different processes. The `monolithic architecture`, based on a single unit assembled and released together, has evolved in a `multi process structure` built on top of a dedicated cloud architecture.

The infrastructure became an important aspect of the software creation process and the cloud computing platforms services are part of the product development.

This repository is a dockerized environment of microservices that handles the placement of an order.

Microservices have been created using `Javascript` and `Ruby` depending on existing products, libraries or for other specific needs and interact using messages.
Each service is extremely specialized and actually responsible for just one task.

The interaction among services is provided by my `Postcard` library. It creates an abstraction layer over RabbitMQ in order to decouple this product from the application.

### Application diagram

![Application diagram](assets/Application-in-the-time-of-microservices.png?raw=true "Application diagram")

### Postcard: An abstraction layer over message brokers

This library, created for both languages `Javascript` and `Ruby`(https://rubygems.org/gems/postcard_rb), is an abstraction layer over `RabbitMQ`. 
It allows the communication among the microservices, providing functionality for publishing and subscribing events.

The microservices interact through topics created with one of three routing types: `Wide`, `Explicit` and `PatternMatching`. 

Each topic may have multiple rooms and, according to the routing type, microservices exchange messages on a different way.

#### Wide topic

Each message published on a wide topic is received by each room connected to it.

```ruby
# Send a message

topic = postcardRB.createTopic(name: "order", routing: Routing.Wide)
topic.publish(payload: "Place a new order")

# Receive a message

topic = postcardRB.createTopic(name: "order", routing: Routing.Wide)
room = topic.createRoom(name: "place")

room.subscribe { |properties, payload|
   puts " [x] Received #{payload}"
}

```

#### Explicit topic

For this kind of topic a message is published on an specific room using its exact name.
 
```ruby
# Send a message

topic = postcardRB.createTopic(name: "order", routing: Routing.Explicit)
topic.publish(room: "place", payload: "Place a new order")

# Receive a message

topic = postcardRB.createTopic(name: "order", routing: Routing.Explicit)
room = topic.createRoom(name: "place")

room.subscribe { |properties, payload|
   puts " [x] Received #{payload}"
}

```

#### Pattern matching topic

Using a pattern matching routing, a microservice subscribe to a room based on matching between a message routing key and the pattern that was used to create that room.

```ruby
# Send a message

topic = postcardRB.createTopic(name: "delivery", routing: Routing.PatternMatching)
topic.publish(room: "sms.customers", payload: "Important news")

# Receive a message

topic = postcardRB.createTopic(name: "delivery", routing: Routing.PatternMatching)
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

```bash
# Change the directory to the docker development 
cd docker/dev

# Create a .env file with your local application folder
echo "APP_FOLDER=/path-to-your-local/app" > .env 

# Run the micro services using docker compose
sudo docker-compose up -d

# Open your browser and type the following address
# to connect to the client application
http://localhost:8080

# And in another tab the following address
# to connect to the vendor application
http://localhost:8081

# Place a new order using the client application button "Insert order".
# The new order will appear directly in the vendor application.
# From this page it is possible to change the order status
# and each update will refresh automatically the client application data.

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

order

* get
* got
* place
* placed
* patch
* patched

orders

* get
* got

dispatcher-manager

* message.place.request.email
* message.place.response.email
* message.send.request.email
* message.send.response.email
* message.sent.email

--------------------------------------------------------------------------------

## Authors

- **Simone Adelchino** - [_claclacla_](https://twitter.com/_claclacla_)

--------------------------------------------------------------------------------

## License

This project is licensed under the MIT License

--------------------------------------------------------------------------------

## Acknowledgments

- [Ruby MongoDB driver](https://docs.mongodb.com/ruby-driver/master/ruby-driver-tutorials/)
- [Postcard: Ruby version](https://rubygems.org/gems/postcard_rb)