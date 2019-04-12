ARG tag
FROM prismagraphql/prisma:$tag

RUN apk update
RUN apk add mariadb-client

COPY ./prerun_hook.sh /app/prerun_hook.sh

CMD /app/start.sh
