FROM ruby:2.5.1-slim

RUN gem install bunny 
RUN gem install interface 
RUN gem install sinatra

EXPOSE 4567

CMD ruby $MICROSERVICE_PATH