const ITopic = require("../../ITopic");

class BaseRabbitMQTopic extends ITopic {
  constructor() {
    super();
  }

  _addRoom(room) {
    this.rooms.push(room);
  }

  createRoom() {

  }

  publish() {

  }
}

module.exports = BaseRabbitMQTopic