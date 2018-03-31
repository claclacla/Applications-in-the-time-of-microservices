var amqp = require('amqplib/callback_api');

start = () => {
  amqp.connect('amqp://rabbitmq:5672', function (err, conn) {
    if(err) {
      console.log("[AMQP] Error:", err);
      return setTimeout(start, 500);
    }

    console.log("[AMQP] Connected");
    
    // Exec

    conn.createChannel(function (err, ch) {
      var q = 'hello';
      var msg = 'Hello World!';
  
      ch.assertQueue(q, { durable: false });
      // Note: on Node 6 Buffer.from(msg) should be used
      ch.sendToQueue(q, new Buffer(msg));
      console.log(" [x] Sent %s", msg);
    });
  });
}

start();