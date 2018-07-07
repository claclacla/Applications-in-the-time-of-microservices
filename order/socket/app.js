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
    console.log("Connection created");
  } catch (error) {
    console.log(error);
    return;
  }

  let topic = messageBroker.createTopic({ name: "order", routing: Routing.Explicit })

  /*
  amqp.connect('amqp://rabbitmq', function(err, conn) {
    console.log("Create channel");
    
    conn.createChannel(function(err, ch) {
      console.log("Channel created");
      
      let channel = ch;
      let ex = 'order';
  
      console.log("Create topic");
      
      channel.assertExchange(ex, 'direct', {durable: false});
  
      console.log("Create room");
      
      channel.assertQueue('on.email.sent', {exclusive: true}, function(err, q) {
        console.log(" [*] Waiting for messages in %s. To exit press CTRL+C", q.queue);
        channel.bindQueue(q.queue, ex, 'on.email.sent');
  
        channel.consume(q.queue, function(msg) {
          let content = msg.content;
  
          console.log(" [x] %s", content.toString());
  
          PubSub.publish("on.email.sent", JSON.parse(content));
        }, {noAck: true});
      });
    });
  });
  */

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

    socket.on('set.order.number', function (payload) {

      // TODO: Add number verification

      orderNumber = parseInt(payload.number);

      PubSub.subscribe("on.email.sent", (msg, data) => {
        console.log(orderNumber, data);

        if (data.order.number !== orderNumber) {
          return;
        }

        console.log("emit to: " + orderNumber);

        socket.emit('message.dispatched', { message: "A new email for the order N." + orderNumber });
      });
    });

    socket.on('disconnect', function () {
      //io.emit('user disconnected');
    });
  });
})();