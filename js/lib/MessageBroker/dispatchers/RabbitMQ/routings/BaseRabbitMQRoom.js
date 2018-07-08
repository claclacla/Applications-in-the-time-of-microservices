const IRoom = require("../../IRoom");

class BaseRabbitMQRoom extends IRoom {
  constructor({ channel, queue }) {
    super();

    this.channel = channel;
    this.queue = queue;
  }

  subscribe(callback) {
    this.channel.consume(this.queue, callback, {noAck: true});
  }
}

module.exports = BaseRabbitMQRoom