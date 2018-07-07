class IDispatcher {
  constructor({ host }) {
    if(host === undefined) {
      throw new Error("host is a required parameter");
    }

    this.host = host;

    if (this.connect === undefined) {
      throw new Error(".connect() is a required method");
    }

    if (this.createTopic === undefined) {
      throw new Error(".createTopic() is a required method");
    }
  }
}

module.exports = IDispatcher