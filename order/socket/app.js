const server = require('http').createServer();
const PubSub = require("pubsub-js");

const printExecutionTime = require("../../js/lib/printExecutionTime");

const RabbitMQDispatcher = require("../../js/lib/MessageBroker/dispatchers/RabbitMQ/RabbitMQDispatcher");
const MessageBroker = require("../../js/lib/MessageBroker/MessageBroker");
const Routing = require("../../js/lib/MessageBroker/Routing");

(async () => {
  const rabbitMQDispatcher = new RabbitMQDispatcher({ host: 'amqp://rabbitmq' });
  const messageBroker = new MessageBroker(rabbitMQDispatcher);

  try {
    await messageBroker.connect();
  } catch (error) {
    return;
  }

  printExecutionTime();

  let topic = messageBroker.createTopic({ name: "message", routing: Routing.Explicit });
  let emailSent = await topic.createRoom({ name: "email.sent" });

  emailSent.subscribe((msg) => {
    let content = msg.content;
    console.log(" [x] %s", content.toString());

    PubSub.publish("email.sent", JSON.parse(content));
  });

  // Start Socket.io server

  const io = require('socket.io')(server, {
    path: '/order',
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

    socket.on("order.subscribe.events", function (payload) {
      console.log("order.subscribe.events", payload);

      orderNumber = payload.number;
    });

    emailSentEvent = PubSub.subscribe("email.sent", function (msg, message) {
      console.log("email.sent", message.order.number, orderNumber);

      if (message.order.number !== orderNumber) {
        return;
      }

      socket.emit('email.sent', { message: "Email sent!" });
    });

    socket.on('disconnect', function () {
      PubSub.unsubscribe(emailSentEvent);
    });

    // let orderNumber = null;

    // PubSub.subscribe("email.sent", (msg, data) => {
    //   console.log(orderNumber, data);

    //   if (data.order.number !== orderNumber) {
    //     return;
    //   }

    //   console.log("emit to: " + orderNumber);

    //   socket.emit('message.dispatched', { message: "A new email for the order N." + orderNumber });
    // });
  });
})();