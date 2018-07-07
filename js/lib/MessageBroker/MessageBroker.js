class MessageBroker {
  constructor(dispatcher) {
    this.connectionRetries = 10;
    this.connectionInterval = 2000;

    this.dispatcher = dispatcher;
  }

  async connect() {
    try {
      await this.dispatcher.connect({
        connectionInterval: this.connectionInterval,
        connectionRetries: this.connectionRetries
      })
    } catch (error) {

      // TODO: Create an application error

      throw new Error("MessageBroker connection refused");
    }
  }

  async createTopic({ name, routing }) {
    let topic = await this.dispatcher.createTopic({ name, routing });
    
    return topic;
  }
}

module.exports = MessageBroker