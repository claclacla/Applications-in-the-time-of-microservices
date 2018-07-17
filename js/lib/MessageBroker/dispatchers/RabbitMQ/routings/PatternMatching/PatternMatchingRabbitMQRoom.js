const BaseRabbitMQRoom = require("../BaseRabbitMQRoom");

class PatternMatchingRabbitMQRoom extends BaseRabbitMQRoom {
  constructor({ channel, queue }) {
    super({ channel, queue });
  }

  static async create({ name, topicName, channel }) {
    return new Promise((resolve, reject) => {
      channel.assertQueue(name, { exclusive: true }, function (err, q) {
        if (err) {
          return reject(err);
        }
        
        channel.bindQueue(q.queue, topicName, name);

        resolve(new PatternMatchingRabbitMQRoom({ channel, queue: q.queue }));
      });
    });
  }
}

module.exports = PatternMatchingRabbitMQRoom