#!/bin/bash

cd /app && yarn && yarn build
cd /app/packages/common && yarn start:dev &
cd /app/packages/ui/ && yarn start:dev &
cd /app/packages/server && yarn start:dev &

wait