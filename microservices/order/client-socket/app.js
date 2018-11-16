const server = require('http').createServer();
const PubSub = require("pubsub-js");

const printExecutionTime = require("../../../js/lib/printExecutionTime");

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

  printExecutionTime();

  let orderTopic = postcard.createTopic({ name: "order", routing: Routing.PatternMatching });
  let orderPatched = await orderTopic.createRoom({ name: "patched" });

  orderPatched.subscribe((msg) => {
    let content = msg.content;
    console.log(" [x] %s", content.toString());

    PubSub.publish("order.patched", { order: JSON.parse(content) });
  });

  // Start Socket.io server

  const io = require('socket.io')(server, {
    path: '/order/client-application',
    serveClient: false,
    pingInterval: 10000,
    pingTimeout: 5000,
    cookie: false
  });

  server.listen(3001);

  // Wait for connections

  io.on('connection', function (socket) {
    let orderNumber = null;
    let orderPatchedEvent = null;

    socket.on("order.events.subscribe", function (payload) {
      console.log("order.events.subscribe", payload);

      orderNumber = payload.number;
    });

    orderPatchedEvent = PubSub.subscribe("order.patched", function (msg, message) {
      console.log("order.patched", message.order.number, orderNumber);

      if (message.order.number !== orderNumber) {
        return;
      }
      
      socket.emit('order.patched', { data: message.order });
    });

    socket.on('disconnect', function () {
      PubSub.unsubscribe(orderPatchedEvent);
    });
  });
})();