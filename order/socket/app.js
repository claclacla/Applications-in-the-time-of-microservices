const amqp = require("amqp");
const server = require('http').createServer();

// Start RabbitMQ connection

var amqpClient = amqp.createConnection({ host: 'rabbitmq' });

amqpClient.on('error', function (e) {
  console.log("RabbitMQ connection error: " + e);
});

amqpClient.on('ready', function () {
  console.log("RabbitMQ connection ready");
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
    orderNumber = payload.number;

    setTimeout(() => {
      socket.emit('message.dispatched', { message: "A new email for the order N." + orderNumber });
    }, 2000);
  });

  socket.on('disconnect', function () {
    //io.emit('user disconnected');
  });
});