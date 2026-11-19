#!/bin/sh
# Attend que chaque hôte:port réponde (60 s max par hôte), puis lance la commande après --.
# nc ou bash selon l'image : aucune des deux méthodes n'est présente dans toutes.

probe() {
    if command -v nc >/dev/null 2>&1; then
        nc -w2 "$1" "$2" </dev/null
    else
        timeout 2 bash -c "</dev/tcp/$1/$2"
    fi
}

while [ "$1" != "--" ]; do
    i=0
    until probe "${1%:*}" "${1#*:}" 2>/dev/null; do
        i=$((i + 1))
        [ "$i" -ge 30 ] && break
        sleep 2
    done
    shift
done
shift
exec "$@"
