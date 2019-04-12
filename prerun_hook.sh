#! /bin/bash

set -e

while ! mysqladmin ping -h"${MYSQL_WAIT_FOR_HOST}" -P"${MYSQL_WAIT_FOR_PORT}"; do
  sleep 1
done
