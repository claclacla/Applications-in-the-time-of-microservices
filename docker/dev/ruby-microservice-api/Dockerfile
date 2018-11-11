FROM ruby:2.5.1

RUN gem install bunny 
RUN gem install interface 
#RUN gem install goliath
RUN gem install postcard_rb

EXPOSE 4567

CMD ruby $MICROSERVICE_PATH