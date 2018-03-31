var amqp = require('amqplib/callback_api');

start = () => {
  amqp.connect('amqp://rabbitmq:5672', function (err, conn) {
    if(err) {
      console.log("[AMQP] Error:", err);
      return setTimeout(start, 500);
    }

    console.log("[AMQP] Connected");
    
    // Exec

    conn.createChannel(function(err, ch) {
      var q = 'hello';
  
      ch.assertQueue(q, {durable: false});
      console.log(" [*] Waiting for messages in %s. To exit press CTRL+C", q);
      ch.consume(q, function(msg) {
        console.log(" [x] Received %s", msg.content.toString());
      }, {noAck: true});
    });
  });
}

start();