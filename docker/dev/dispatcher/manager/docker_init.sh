#!/bin/bash

echo "
Install node packages...
"

npm install --prefix /usr/src/app/dispatcher/manager

echo "
Start pm2 process...
"

pm2 start /usr/src/app/dispatcher/manager/app.js

echo "
Print pm2 logs...
"

pm2 logs 0