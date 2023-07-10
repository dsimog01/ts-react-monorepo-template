#!/bin/bash

cd /app && npm i && npm run build
cd /app/packages/common && npm run start:dev &
cd /app/packages/ui/ && npm run start:dev &
cd /app/packages/server && npm run start:dev &

wait