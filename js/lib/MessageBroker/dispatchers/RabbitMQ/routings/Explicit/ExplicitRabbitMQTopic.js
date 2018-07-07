const BaseRabbitMQTopic = require("../BaseRabbitMQTopic");

class ExplicitRabbitMQTopic extends BaseRabbitMQTopic {
  constructor({ name, channel }) {
    super();

    this.channel = channel;
    channel.assertExchange(name, 'direct', {durable: false});
  }

  createRoom() {

  }

  publish() {

  }
}

module.exports = ExplicitRabbitMQTopic