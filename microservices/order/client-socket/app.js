const server = require('http').createServer();
const PubSub = require("pubsub-js");

const printExecutionTime = require("../../../js/lib/printExecutionTime");

const RabbitMQDispatcher = require("../../../js/lib/MessageBroker/dispatchers/RabbitMQ/RabbitMQDispatcher");
const MessageBroker = require("../../../js/lib/MessageBroker/MessageBroker");
const Routing = require("../../../js/lib/MessageBroker/Routing");

(async () => {
  const rabbitMQDispatcher = new RabbitMQDispatcher({ host: 'amqp://rabbitmq' });
  const messageBroker = new MessageBroker(rabbitMQDispatcher);

  try {
    await messageBroker.connect();
  } catch (error) {
    return;
  }

  printExecutionTime();

  let orderTopic = messageBroker.createTopic({ name: "order", routing: Routing.Explicit });
  let orderUpdated = await orderTopic.createRoom({ name: "updated" });

  orderUpdated.subscribe((msg) => {
    let content = msg.content;
    console.log(" [x] %s", content.toString());

    PubSub.publish("order.updated", JSON.parse(content));
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
    let emailSentEvent = null;

    socket.on("order.events.subscribe", function (payload) {
      console.log("order.events.subscribe", payload);

      orderNumber = payload.number;
    });

    emailSentEvent = PubSub.subscribe("order.updated", function (msg, message) {
      console.log("order.updated", message.order.number, orderNumber);

      if (message.order.number !== orderNumber) {
        return;
      }

      socket.emit('order.updated', { message: order });
    });

    socket.on('disconnect', function () {
      PubSub.unsubscribe(emailSentEvent);
    });
  });
})();