const express = require('express');
const PubSub = require("pubsub-js");
const router = express.Router();

//const HttpError = require("../../errors/HttpError");

const RabbitMQDispatcher = require('postcard-js/dispatchers/RabbitMQ/RabbitMQDispatcher');
const Postcard = require('postcard-js/Postcard');
const Routing = require('postcard-js/Routing');

(async () => {
  const rabbitMQDispatcher = new RabbitMQDispatcher({ host: 'amqp://rabbitmq' });
  const postcard = new Postcard(rabbitMQDispatcher);

  try {
    await postcard.connect();
  } catch (error) {
    return;
  }

  let orderTopic = postcard.createTopic({ name: "order", routing: Routing.PatternMatching });

  // order.place, order.placed

  let onOrderPlaced = await orderTopic.createRoom({ name: "placed" });

  PubSub.subscribe("order.place", (msg, payload) => {
    orderTopic.publish({ room: "place", payload: JSON.stringify(payload) });
  });

  onOrderPlaced.subscribe((msg) => {
    let content = msg.content;

    PubSub.publish("order.placed", JSON.parse(content));
  });

  // order.get, order.got

  let onOrderGot = await orderTopic.createRoom({ name: "got" });

  PubSub.subscribe("order.get", (msg, payload) => {
    orderTopic.publish({ room: "get", payload });
  });

  onOrderGot.subscribe((msg) => {
    let content = msg.content;

    PubSub.publish("order.got", JSON.parse(content));
  });

  // order.patch, order.patched

  let onOrderPatched = await orderTopic.createRoom({ name: "patched" });

  PubSub.subscribe("order.patch", (msg, payload) => {
    orderTopic.publish({ room: "patch.replace", payload: JSON.stringify(payload) });
  });

  onOrderPatched.subscribe((msg) => {
    let content = msg.content;

    PubSub.publish("order.patched", JSON.parse(content));
  });
})();

router
  .post('/', function (req, res, next) {
    let orderDto = req.body;

    PubSub.publish("order.place", orderDto);

    PubSub.subscribe("order.placed", (msg, order) => {
      PubSub.unsubscribe("order.placed");

      res.status(201).send({
        data: order
      });
    });
  })
  .get('/:uid', function (req, res, next) {
    let uid = req.params.uid;

    PubSub.publish("order.get", uid);

    PubSub.subscribe("order.got", (msg, order) => {
      PubSub.unsubscribe("order.got");

      // if(!source) { 
      //   return next(HttpError.NotFound());
      // }

      res.send({
        data: order
      });
    });
  })

  // status

  .put('/:uid/status', function (req, res, next) {
    let uid = req.params.uid;
    let statusDto = req.body;

    // TODO: Add a mapper
    
    PubSub.publish("order.patch", { uid, patch: statusDto });

    PubSub.subscribe("order.patched", (msg, order) => {
      PubSub.unsubscribe("order.patched");

      res.send({
        data: order
      });
    });
  })

module.exports = router;