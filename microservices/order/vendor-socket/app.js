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

  // orders.* events

  // let ordersTopic = messageBroker.createTopic({ name: "orders", routing: Routing.Explicit });
  // let onOrdersGot = await ordersTopic.createRoom({ name: "got" });

  // onOrdersGot.subscribe((msg) => {
  //   let content = msg.content;

  //   PubSub.publish("orders.got", { orders: JSON.parse(content) });
  // });

  // order.* events

  let orderTopic = messageBroker.createTopic({ name: "order", routing: Routing.PatternMatching });
  let onOrderPlaced = await orderTopic.createRoom({ name: "placed" });

  onOrderPlaced.subscribe((msg) => {
    let content = msg.content;
    let order = JSON.parse(content);

    PubSub.publish("order.placed", { order });
  });

  // Start Socket.io server

  const io = require('socket.io')(server, {
    path: '/order/vendor-application',
    serveClient: false,
    pingInterval: 10000,
    pingTimeout: 5000,
    cookie: false
  });

  server.listen(3002);

  // Wait for connections

  io.on('connection', function (socket) {
    let orderPlacedEvent = PubSub.subscribe("order.placed", function (msg, message) {
      let order = message.order;
      
      socket.emit('order.placed', {
        data: order.uid
      });
    });

    socket.on('disconnect', function () {
      PubSub.unsubscribe(orderPlacedEvent);
    });
  });
})();