#!/bin/bash

echo "
Install npm packages for node app...
"

npm install --prefix $MICROSERVICE_PATH
npm start --prefix $MICROSERVICE_PATH