const amqp = require("amqplib/callback_api");
const sleep = require("../sleep");

class MessageBroker {
  constructor() {
    this.connectionRetries = 10;
    this.connectionInterval = 2000;

    this.conn = null;
  }

  openConnection() {
    return new Promise((resolve, reject) => {
      amqp.connect('amqp://rabbitmq', (err, conn) => {
        if (err) {
          return reject(err);
        }

        resolve(conn);
      });
    });
  }

  async connect() {
    for (let i = 0; i < this.connectionRetries; i++) {
      console.log(i);

      try {
        this.conn = await this.openConnection();
        return;
      } catch (error) {        
        await sleep(this.connectionInterval);
      }
    }

    throw new Error("Dispatcher connection refused");
  }
}

module.exports = MessageBroker