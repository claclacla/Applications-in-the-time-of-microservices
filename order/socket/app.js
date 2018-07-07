//const amqp = require("amqp");
const server = require('http').createServer();

var amqp = require('amqplib/callback_api');

amqp.connect('amqp://rabbitmq', function(err, conn) {
  conn.createChannel(function(err, ch) {
    var ex = 'order';

    ch.assertExchange(ex, 'direct', {durable: false});

    ch.assertQueue('on.email.sent', {exclusive: true}, function(err, q) {
      console.log(" [*] Waiting for messages in %s. To exit press CTRL+C", q.queue);
      ch.bindQueue(q.queue, ex, 'on.email.sent');

      ch.consume(q.queue, function(msg) {
        console.log(" [x] %s", msg.content.toString());
      }, {noAck: true});
    });
  });
});

/*
// Start RabbitMQ connection

var amqpClient = amqp.createConnection({ host: 'rabbitmq' });

amqpClient.on('error', function (e) {
  console.log("RabbitMQ connection error: " + e);
});

amqpClient.on('ready', function () {
  console.log("RabbitMQ connection ready");
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
    orderNumber = payload.number;

    setTimeout(() => {
      socket.emit('message.dispatched', { message: "A new email for the order N." + orderNumber });
    }, 2000);
  });

  socket.on('disconnect', function () {
    //io.emit('user disconnected');
  });
});