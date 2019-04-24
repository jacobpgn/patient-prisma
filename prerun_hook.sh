#! /bin/bash

set -e

while ! nc -z $WAIT_FOR_HOST $WAIT_FOR_PORT; do
  sleep 1
done
