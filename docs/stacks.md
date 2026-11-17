# Stacks

Une stack par dossier, déclarée dans `komodo/stacks.toml`.

## Swarm

| Stack             | Rôle                                     | Exposition                      |
| ----------------- | ---------------------------------------- | ------------------------------- |
| `traefik`         | reverse proxy                            | point d'entrée                  |
| `authelia`        | SSO, LLDAP, PostgreSQL                   | internet ; LLDAP en LAN only    |
| `crowdsec`        | IDS, bouncer dans Traefik                | interne                         |
| `komodo`          | orchestrateur                            | LAN only ; webhooks             |
| `vaultwarden`     | mots de passe                            | internet ; `/admin` en LAN only |
| `immich`          | photos                                   | internet                        |
| `bookstack`       | wiki                                     | internet                        |
| `tracearr`        | stats de lecture                         | internet                        |
| `mediarr`         | Prowlarr, Radarr, Sonarr, Bazarr, Seerr… | LAN + SSO ; Seerr sur internet  |
| `wizarr`          | invitations Jellyfin                     | invitations seules sur internet |
| `notify`          | ntfy, Apprise                            | ntfy sur internet               |
| `monitoring`      | Prometheus, Loki, Grafana, Alloy         | LAN only                        |
| `cloudflare-ddns` | IP publique dans le DNS                  | aucune                          |

Placement par label de nœud. Toutes les bases sont sur le même nœud.

## Hors Swarm

| Stack         | Hôte           | Pourquoi                                |
| ------------- | -------------- | --------------------------------------- |
| `jellyfin`    | `link`         | transcodage GPU, non supporté par Swarm |
| `seedbox`     | `merovingian`  | qBittorrent dans le réseau de gluetun   |
| `mailcow`     | `persephone`   | structure et outil d'update propres     |
| `forgejo`     | `controlplane` | sur le VPS, indépendant du cluster      |
| `gatus`       | `controlplane` | monitoring depuis l'extérieur           |
| `traefik-vps` | `controlplane` | reverse proxy du VPS                    |

## Mailcow

Clone du dépôt officiel, adopté par Komodo (`files_on_host`) pour la visibilité.
Une action Komodo signale les nouvelles releases, l'update se fait avec
`update.sh`.
