const server = require('http').createServer();
const PubSub = require("pubsub-js");

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

    //socket.on("", function(payload) {

    //});

    // PubSub.subscribe("email.sent", (msg, data) => {
    //   console.log(orderNumber, data);

    //   if (data.order.number !== orderNumber) {
    //     return;
    //   }

    //   console.log("emit to: " + orderNumber);

    //   socket.emit('message.dispatched', { message: "A new email for the order N." + orderNumber });
    // });
  });

  socket.on('disconnect', function () {
    //io.emit('user disconnected');
  });
})();