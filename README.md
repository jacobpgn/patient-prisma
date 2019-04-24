# Patient Prisma

[Prisma](https://hub.docker.com/r/prismagraphql/prisma/), but it waits patiently
until the database is up.

This was made to help test with Prisma on CircleCI's Docker environment, where
it isn't possible to use Docker Compose in the way Prisma's docs suggest.

If you specify something like:
```yml
  - image: postgres:11
  - image: prisma/prisma:1.30.1
```
in your CircleCI config, those two images will race to start. If Prisma tries
to connect to the database before the database is listening, Prisma will exit.

Fortunately Prisma offers a [prerun hook script](https://github.com/prisma/prisma/blob/50ba03f7248b59cb1dd3b1911b415de79b851cc4/server/prerun_hook.sh), so this project
simply adds a check there to wait until the database is up.

You probably don't want to use this in production as-is. There's no timeout, it
only checks that the host + port is accepting connections (which might not mean
that the database is also healthy and ready) and it will just keep trying every
second until the given host responds or the world ends.

## Usage

Simply start this image with:
`WAIT_FOR_HOST` and `WAIT_FOR_PORT`
set to the details of the database you need to wait for.

### Usage on CircleCI

Example config:

```yml
version: 3

jobs:
  run_tests:
    docker:
      - image: circleci/node:lts

      - image: postgres:11
        environment:
          POSTGRES_USER: prisma_user
          POSTGRES_PASSWORD: prisma_password

      - image: jacobpgn/patient-prisma:1.30.1
        environment:
          PRISMA_CONFIG: |
            port: 4466
            databases:
              default:
                connector: postgres
                host: localhost
                port: 5432
                user: prisma_user
                password: prisma_password
                migrations: true
          WAIT_FOR_HOST: localhost
          WAIT_FOR_PORT: 5432

    steps:
      - checkout
      - run: yarn install
      - run: yarn test

workflows:
  version: 2

  test:
    jobs:
      - run_tests

```
