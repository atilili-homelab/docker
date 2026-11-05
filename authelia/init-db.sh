authelia_db_password="$(cat /run/secrets/authelia_db_password)"
lldap_db_password="$(cat /run/secrets/lldap_db_password)"

psql -v ON_ERROR_STOP=1 \
    -v authelia_pw="$authelia_db_password" \
    -v lldap_pw="$lldap_db_password" \
    --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<'EOSQL'
CREATE ROLE authelia LOGIN PASSWORD :'authelia_pw';
CREATE DATABASE "authelia" OWNER authelia;
REVOKE CONNECT ON DATABASE "authelia" FROM PUBLIC;
CREATE ROLE lldap LOGIN PASSWORD :'lldap_pw';
CREATE DATABASE "lldap" OWNER lldap;
REVOKE CONNECT ON DATABASE "lldap" FROM PUBLIC;
EOSQL
