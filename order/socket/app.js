const amqp = require("amqp");
const server = require('http').createServer();

const io = require('socket.io')(server, {
  path: '/order',
  serveClient: false,
  pingInterval: 10000,
  pingTimeout: 5000,
  cookie: false
});

server.listen(3001);

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