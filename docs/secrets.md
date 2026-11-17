# Secrets

Aucun secret dans le dépôt ni dans Komodo. OpenBao est la source, Ansible crée
les secrets Swarm (rôle `swarm_secrets` du dépôt Ansible).

## Nommage

Le champ `<champ>` de `services/<service>` devient le secret
`<service>_<champ>_v<N>`, s'il est déclaré dans la custom metadata du chemin
(`<champ>=<N>`).

Dans le compose, la clé reste fixe, seul le nom est versionné :

```yaml
secrets:
    komodo_db_password: { name: komodo_db_password_v1, external: true }
```

Le fichier monté reste `/run/secrets/komodo_db_password` : une rotation ne
touche pas la config de l'appli.

## Lecture par l'appli

Par ordre de préférence :

1. variable `_FILE` native ;
2. préfixe `FILE__` des images LinuxServer ;
3. `_shared/file-env.sh` en entrypoint, qui convertit les `<NOM>_FILE` ;
4. config Swarm templatée (`{{ secret "nom" }}`) pour une URL ou un fichier.

Jamais de secret en variable d'environnement : il serait visible dans
`docker service inspect`.

## Hors Swarm

Ansible écrit les secrets dans `/etc/docker-secrets/` sur l'hôte, montés en
fichier ou en `env_file`.

## Rotation

1. Nouvelle valeur dans OpenBao.
2. Metadata à `N+1`.
3. `_v<N+1>` dans le compose, push.
4. Le playbook crée la nouvelle version, et supprime l'ancienne au passage
   suivant.

## Pièges

- Docker refuse de supprimer un secret utilisé : le ménage est sans risque.
