const express = require('express');
const PubSub = require("pubsub-js");
const router = express.Router();

//const HttpError = require("../../errors/HttpError");

const RabbitMQDispatcher = require("../../../js/lib/MessageBroker/dispatchers/RabbitMQ/RabbitMQDispatcher");
const MessageBroker = require("../../../js/lib/MessageBroker/MessageBroker");
const Routing = require("../../../js/lib/MessageBroker/Routing");

console.log("start");

(async () => {
  const rabbitMQDispatcher = new RabbitMQDispatcher({ host: 'amqp://rabbitmq' });
  const messageBroker = new MessageBroker(rabbitMQDispatcher);

  try {
    await messageBroker.connect();
    console.log("Connection created");
  } catch (error) {
    console.log(error);
    return;
  }

  let topic = messageBroker.createTopic({ name: "order", routing: Routing.Explicit });
  let onOrderPlaced = await topic.createRoom({ name: "on.placed" });

  PubSub.subscribe("on.place", (msg, payload) => {
    topic.publish({ room: "on.place", payload: JSON.stringify(payload) });
  });
  
  onOrderPlaced.subscribe((msg) => {
    let content = msg.content;
    console.log("on placed");
    console.log(" [x] %s", content.toString());

    PubSub.publish("on.placed", JSON.parse(content));
  });
})();

router
  .post('/', function (req, res, next) {
    let orderDto = req.body;

    PubSub.publish("on.place", orderDto);

    PubSub.subscribe("on.placed", (msg, payload) => {
      PubSub.unsubscribe("on.placed");

      res.status(201).send({
        data: orderDto
      });
    });
  });

module.exports = router;