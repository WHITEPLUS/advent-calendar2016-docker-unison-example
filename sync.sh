#! /usr/bin/env bash

LOCAL_DIR=./webapp
REMOTE_DIR=/var/www/piyo
REMOTE_CID=piyo_data

recv_local() {
  while read -r event; do
    test -n "${event}" && \
    echo "LOCAL: ${event}" >> events.log
  done
}

recv_remote() {
  while read -r event; do
    event=$(echo -n $event \
    | grep -E '(CREATE|MOVE|MOVED_TO|MOVED_FROM|MODIFY|ATTRIB|DELETE|DELETE_SELF)[,:]' \
    | sed -e 's/^[A-Z,_]*://g' \
    | tr -d '\n')
    test -n "${event}" && \
    echo "REMOTE: ${event}" >> events.log
  done
}

UNISON="unison ${LOCAL_DIR} socket://127.0.0.1:5000/ -auto -batch"

${UNISON}

rm -f events.log
touch events.log

fswatch ${LOCAL_DIR} 2>&1 | recv_local &
CHILDREN=$!

docker exec -it ${REMOTE_CID} inotifywait -m -r --format '%e:%w%f' ${REMOTE_DIR} 2>&1 | recv_remote &
CHILDREN="${CHILDREN} $!"

trap "kill -KILL ${CHILDREN} > /dev/null 2>&1" INT TERM

tail -f ./events.log | xargs -I{} ${UNISON}
