#!/bin/sh
set -eu

# Add _FILE convention to read secrets from files
# Loop searching for var ending with _FILE=
# If found, read the file and export the variable with the same name without _FILE
# and the content of the file as value
#
# Example:
#   export MY_VAR_FILE=/path/to/file
#   will export MY_VAR with the content of /path/to/file
#   and unset MY_VAR_FILE
#   if /path/to/file does not exist or is not readable, exit with error
#
# This is useful to read secrets from files in a container
# and avoid having secrets visible with docker service inspect
# or docker inspect
#
# Usage :
#   Put this script in front of the image's original entrypoint, and give the
#   image's origin command as command. Find both with:
#     docker image inspect <image> --format '{{.Config.Entrypoint}}{{.Config.Cmd}}'
# Compose example (redis:7 -> [docker-entrypoint.sh] [redis-server]):
#   services:
#     redis:
#       image: redis:7
#       entrypoint: ["/file-env.sh", "/docker-entrypoint.sh"]
#       command: [redis-server]
#       environment:
#         REDIS_PASSWORD_FILE: /run/secrets/redis_password
#       secrets:
#         - redis_password
#       configs:
#         - source : file-env
#           target: /file-env.sh
#           mode: 0555
#   configs:
#     file-env:
#       file: ../_shared/file-env.sh
#   secrets:
#     redis_password:
#       external: true

# shellcheck disable=SC2154 # $path is defined by eval
for v in $(env | grep '^[A-Za-z0-9_]*_FILE=' | cut -d= -f1); do
    name="${v%_FILE}"
    eval "path=\$$v"
    if [ ! -r "$path" ]; then
        echo "$v : file $path does not exist or unreadable" >&2
        exit 1
    fi
    content=$(cat "$path")
    export "$name=$content"
    unset "$v"
done

# Run the command
exec "$@"
