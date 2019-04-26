#! /bin/bash

set -e

if [ "$#" -ne 1 ]; then
  echo "prismagraphql/prisma tag required, e.g."
  echo "./build_and_push_tag.sh 1.30"
  exit 1
fi

PRISMA_TAG=$1

docker build --build-arg tag="${PRISMA_TAG}" . -t "jacobpgn/patient-prisma:${PRISMA_TAG}"
docker push jacobpgn/patient-prisma:"${PRISMA_TAG}"

echo "Built and pushed! jacobpgn/patient-prisma:${PRISMA_TAG}"
