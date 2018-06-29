# Applications in the time of microservices

## Break up your application into smaller dockerized microservices

### Simple topics

#### Send a message

topic = messageBroker.createTopic(name: "order", routing: Routing.Wide)
topic.publish(payload: "Place a new order")

#### Receive a message

topic = messageBroker.createTopic(name: "order", routing: Routing.Wide)
room = topic.createRoom(name: "place")

room.subscribe { |properties, payload|
   puts " [x] Received #{payload}"
}

### Multi rooms topics

#### Send a message

topic = messageBroker.createTopic(name: "order", routing: Routing.Explicit)
topic.publish(room: "place", payload: "Place a new order")

#### Receive a message

topic = messageBroker.createTopic(name: "order", routing: Routing.Explicit)
room = topic.createRoom(name: "place")

room.subscribe { |properties, payload|
   puts " [x] Received #{payload}"
}

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

# Create a .env file with your local environment variables
echo "APP_FOLDER=/path-to-your-local/app" > .env 

# Run the micro services using docker compose
sudo docker-compose up -d

# Verify the microservices environment placing a new order
curl -X POST localhost:3000/order -d ''

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