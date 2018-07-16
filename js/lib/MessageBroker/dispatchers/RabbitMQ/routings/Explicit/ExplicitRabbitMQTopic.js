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

  publish({ room, payload }) {
    this.channel.publish(this.name, room, new Buffer(payload));
  }
}

module.exports = ExplicitRabbitMQTopic