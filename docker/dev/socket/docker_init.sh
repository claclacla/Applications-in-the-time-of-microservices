#!/bin/bash

echo "
Install npm packages for node app...
"

npm install --prefix /usr/src/app
node $MICROSERVICE_PATH