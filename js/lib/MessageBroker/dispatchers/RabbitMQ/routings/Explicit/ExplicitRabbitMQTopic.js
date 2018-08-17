const BaseRabbitMQTopic = require("../BaseRabbitMQTopic");
const ExplicitRabbitMQRoom = require("./ExplicitRabbitMQRoom");

class ExplicitRabbitMQTopic extends BaseRabbitMQTopic {
  constructor({ name, channel }) {
    super();

    this.name = name;
    this.channel = channel;
    this.channel.assertExchange(name, 'direct', {durable: false});
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

  publish({ room, payload, options }) {
    this.channel.publish(this.name, room, new Buffer(payload), options);
  }
}

module.exports = ExplicitRabbitMQTopic