const express = require('express');
const PubSub = require("pubsub-js");
const router = express.Router();

//const HttpError = require("../../errors/HttpError");

const RabbitMQDispatcher = require("../../../../js/lib/MessageBroker/dispatchers/RabbitMQ/RabbitMQDispatcher");
const MessageBroker = require("../../../../js/lib/MessageBroker/MessageBroker");
const Routing = require("../../../../js/lib/MessageBroker/Routing");

(async () => {
  const rabbitMQDispatcher = new RabbitMQDispatcher({ host: 'amqp://rabbitmq' });
  const messageBroker = new MessageBroker(rabbitMQDispatcher);

  try {
    await messageBroker.connect();
  } catch (error) {
    return;
  }

  // order.* events

  let orderTopic = messageBroker.createTopic({ name: "order", routing: Routing.Explicit });
  let onOrderPlaced = await orderTopic.createRoom({ name: "placed" });

  PubSub.subscribe("order.place", (msg, payload) => {
    orderTopic.publish({ room: "place", payload: JSON.stringify(payload) });
  });

  onOrderPlaced.subscribe((msg) => {
    let content = msg.content;

    PubSub.publish("order.placed", JSON.parse(content));
  });

  // orders.* events

  let ordersTopic = messageBroker.createTopic({ name: "orders", routing: Routing.Explicit });
  let onOrdersGot = await ordersTopic.createRoom({ name: "got" });

  PubSub.subscribe("orders.get", (msg, payload) => {
    ordersTopic.publish({ room: "get", payload: JSON.stringify(payload) });
  });

  onOrdersGot.subscribe((msg) => {
    let content = msg.content;

    PubSub.publish("orders.got", JSON.parse(content));
  });
})();

router
  .get('/', function (req, res, next) {
    PubSub.publish("orders.get");

    PubSub.subscribe("orders.got", (msg, orders) => {
      PubSub.unsubscribe("orders.got");

      res.status(200).send({
        data: orders
      });
    });
  })
  .post('/', function (req, res, next) {
    let orderDto = req.body;

    PubSub.publish("order.place", orderDto);

    PubSub.subscribe("order.placed", (msg, order) => {
      PubSub.unsubscribe("order.placed");

      res.status(201).send({
        data: order
      });
    });
  });

module.exports = router;