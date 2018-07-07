const amqp = require("amqplib/callback_api");
const sleep = require("../../../sleep");

const IDispatcher = require("../IDispatcher");

class RabbitMQDispatcher extends IDispatcher {
  constructor({ host }) {
    super({ host });

    this.conn = null;
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

  async connect({ connectionInterval, connectionRetries }) {
    for (let i = 0; i < connectionRetries; i++) {
      console.log(i);

      try {
        this.conn = await this._openConnection();
        return;
      } catch (error) {
        await sleep(connectionInterval);
      }
    }

    throw new Error("Dispatcher connection refused");
  }

  createTopic() {

  }
}

module.exports = RabbitMQDispatcher