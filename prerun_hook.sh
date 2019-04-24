#! /bin/bash

set -e

while ! nc -z $WAIT_FOR_HOST $WAIT_FOR_PORT; do
  echo "Waiting for ${WAIT_FOR_HOST}:${WAIT_FOR_PORT}..."
  sleep 1
done
