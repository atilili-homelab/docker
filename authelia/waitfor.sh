#!/bin/sh
# Attend que chaque hôte:port réponde (60s max), puis lance la commande après --
while [ "$1" != "--" ]; do
    timeout 60 sh -c "until nc -w2 ${1%:*} ${1#*:} </dev/null; do sleep 2; done" 2>/dev/null
    shift
done
shift
exec "$@"
