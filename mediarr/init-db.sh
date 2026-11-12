create() {
    role=$1
    shift
    psql -v ON_ERROR_STOP=1 -v role="$role" \
        -v pw="$(cat /run/secrets/"$role"_db_password)" \
        --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<'EOSQL'
CREATE ROLE :"role" LOGIN PASSWORD :'pw';
EOSQL
    for db in "$@"; do
        createdb --username "$POSTGRES_USER" --owner "$role" "$db"
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" \
            -c "REVOKE CONNECT ON DATABASE \"$db\" FROM PUBLIC;"
    done
}

create prowlarr prowlarr-main prowlarr-log
create radarr radarrhd-main radarrhd-log radarr4k-main radarr4k-log
create sonarr sonarrhd-main sonarrhd-log sonarr4k-main sonarr4k-log
create bazarr bazarr
create seerr seerr
