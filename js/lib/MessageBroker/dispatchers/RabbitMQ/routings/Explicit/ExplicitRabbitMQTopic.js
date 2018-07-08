const BaseRabbitMQTopic = require("../BaseRabbitMQTopic");
const ExplicitRabbitMQRoom = require("./ExplicitRabbitMQRoom");

class ExplicitRabbitMQTopic extends BaseRabbitMQTopic {
  constructor({ name, channel }) {
    super();

    this.name = name;
    this.channel = channel;
    channel.assertExchange(name, 'direct', {durable: false});
  }

  async createRoom({ name }) {
    let room = await ExplicitRabbitMQRoom.create({ 
      name, 
      topicName: this.name, 
      channel: this.channel 
    });

    this._addRoom(room);

    return room;
  }

  publish() {

  }
}

module.exports = ExplicitRabbitMQTopic