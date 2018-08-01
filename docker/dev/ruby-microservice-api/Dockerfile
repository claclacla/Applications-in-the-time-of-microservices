FROM ruby:2.5.1

RUN gem install bunny 
RUN gem install interface 
#RUN gem install sinatra
RUN gem install goliath

EXPOSE 4567

CMD ruby $MICROSERVICE_PATH