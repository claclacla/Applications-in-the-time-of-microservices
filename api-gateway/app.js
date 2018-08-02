const express = require('express');
const path = require('path');
const bodyParser = require('body-parser');

const printExecutionTime = require("../js/lib/printExecutionTime");

const order = require('./routes/order/index');

const app = express();

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));

app.use(function (req, res, next) {
  let origin = req.headers.origin;

  res.set('Access-Control-Allow-Origin', origin);
  res.set("Access-Control-Allow-Credentials", true);
  res.set("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept, Credentials");

  res.set("Content-Type", "application/json");

  if (req.method == "OPTIONS") {
    res.set("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE");
    return res.sendStatus(200);
  }

  next();
});

app.use('/order', order);

// error handler

app.use(function (err, req, res, next) {
  if (err === undefined) {
    return next();
  }

  res.status(err.status || 500).send({
    status: err.status,
    message: err.message
  });
});

printExecutionTime();

app.listen(3000);

module.exports = app;