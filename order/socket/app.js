const server = require('http').createServer();
const amqp = require('amqplib/callback_api');
const PubSub = require("pubsub-js");

let channel = null;

amqp.connect('amqp://rabbitmq', function(err, conn) {
  conn.createChannel(function(err, ch) {
    channel = ch;
    let ex = 'order';

    channel.assertExchange(ex, 'direct', {durable: false});

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
      
      if(data.order.number !== orderNumber) {
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