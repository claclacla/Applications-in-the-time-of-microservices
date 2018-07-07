class ITopic {
  constructor() {
    if (this.createRoom === undefined) {
      throw new Error(".createRoom() is a required method");
    }

    if (this.publish === undefined) {
      throw new Error(".publish() is a required method");
    }

    this.rooms = [];
  }
}

module.exports = ITopic