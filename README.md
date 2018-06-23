# Applications in the time of microservices

## Break up your application into smaller dockerized microservices

Currently under development...

--------------------------------------------------------------------------------

### Prerequisites

What things you need to install the software

```
docker 17+
docker-compose 1.19.0+
```

--------------------------------------------------------------------------------

### Installing

```
# Create a .env file with your local environment variables
echo "APP_FOLDER=/path-to-your-local/app" > .env 

```

--------------------------------------------------------------------------------

### Testing

```
#

```

--------------------------------------------------------------------------------

### Usage

```
# Change the directory to the docker development 
cd docker/dev

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