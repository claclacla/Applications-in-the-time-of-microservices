const amqp = require("amqplib/callback_api");
const sleep = require("../../../sleep");

const IDispatcher = require("../IDispatcher");
const Routing = require("../../Routing");
const ExplicitRabbitMQTopic = require("./routings/Explicit/ExplicitRabbitMQTopic");

class RabbitMQDispatcher extends IDispatcher {
  constructor({ host }) {
    super({ host });

    this.conn = null;
    this.channel = null;
  }

  _openConnection() {
    return new Promise((resolve, reject) => {
      amqp.connect(this.host, (err, conn) => {
        if (err) {
          return reject(err);
        }

        resolve(conn);
      });
    });
  }

  _createChannel() {
    return new Promise((resolve, reject) => {
      this.conn.createChannel((err, channel) => {
        if (err) {
          return reject(err);
        }

        resolve(channel);
      });
    });
  }

  // TODO: Return two different errors for connection and channel

  async connect({ connectionInterval, connectionRetries }) {
    for (let i = 0; i < connectionRetries; i++) {
      console.log(i);

      try {
        this.conn = await this._openConnection();
        this.channel = await this._createChannel();

        return;
      } catch (error) {
        await sleep(connectionInterval);
      }
    }

    // TODO: Create an application error

    throw new Error("Dispatcher connection refused");
  }

  createTopic({ name, routing }) {
    let topic = null;

    // TODO: Add the other two cases

    switch (routing) {
      case Routing.Explicit:
        topic = new ExplicitRabbitMQTopic({ name, channel: this.channel })
        break;
    }

    this.topics.push(topic);

    return topic;
  }
}

module.exports = RabbitMQDispatcher