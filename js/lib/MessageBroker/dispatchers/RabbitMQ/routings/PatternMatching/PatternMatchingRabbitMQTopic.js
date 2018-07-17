const BaseRabbitMQTopic = require("../BaseRabbitMQTopic");
const PatternMatchingRabbitMQRoom = require("./PatternMatchingRabbitMQRoom");

class PatternMatchingRabbitMQTopic extends BaseRabbitMQTopic {
  constructor({ name, channel }) {
    super();

    this.name = name;
    this.channel = channel;
    channel.assertExchange(name, 'topic', {durable: false});
  }

  async createRoom({ name }) {
    let room = await PatternMatchingRabbitMQRoom.create({ 
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

module.exports = PatternMatchingRabbitMQTopic