FROM ruby:2.5.1-slim

RUN gem install bunny 
RUN gem install interface

CMD ruby /usr/src/app/order/notifications-dispatcher/app.rb