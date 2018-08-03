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

  let topic = messageBroker.createTopic({ name: "order", routing: Routing.Explicit });
  let onOrderPlaced = await topic.createRoom({ name: "placed" });

  PubSub.subscribe("order.place", (msg, payload) => {  
    topic.publish({ room: "place", payload: JSON.stringify(payload) });
  });
  
  onOrderPlaced.subscribe((msg) => {
    let content = msg.content;
    
    PubSub.publish("order.placed", JSON.parse(content));
  });
})();

router
  .post('/', function (req, res, next) {
    let orderDto = req.body;

    PubSub.publish("order.place", orderDto);

    PubSub.subscribe("order.placed", (msg, payload) => {
      PubSub.unsubscribe("order.placed");

      res.status(201).send({
        data: {
          order: payload
        }
      });
    });
  });

module.exports = router;