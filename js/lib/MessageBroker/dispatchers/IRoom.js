class IRoom {
  constructor() {
    if (this.subscribe === undefined) {
      throw new Error(".subscribe() is a required method");
    }
  }
}

module.exports = IRoom