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
  socket.on('message', function (msg) {
    socket.emit('message', msg);
  });

  socket.on('disconnect', function () {
    //io.emit('user disconnected');
  });
});