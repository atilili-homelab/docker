# Accès

Tout le trafic HTTP passe par Traefik, en global sur plusieurs nœuds, derrière
une IP virtuelle. Pas de proxy Cloudflare : incompatible avec le streaming
Jellyfin.

## Traefik

- Certificats Let's Encrypt par DNS challenge Cloudflare.
- Discovery des services Swarm par labels, via un socket-proxy read-only.
- Routes manuelles (`traefik/external.yml`) pour ce qui est hors Swarm :
  Proxmox, PBS, NAS, Jellyfin, Mailcow, seedbox.

## Réseaux

| Réseau             | Porté par  | Rôle                                |
| ------------------ | ---------- | ----------------------------------- |
| `traefik-wan`      | `traefik`  | services exposés sur internet       |
| `traefik-lan`      | `traefik`  | services LAN only                   |
| `crowdsec-bouncer` | `crowdsec` | Traefik ↔ CrowdSec                  |
| `ldap-network`     | `authelia` | LLDAP, ouvert aux applis hors Swarm |

Un réseau partagé est déclaré par la stack qui le porte, les autres le
rejoignent en `external`. Chaque base a son réseau privé.

Un service sur plusieurs réseaux doit avoir le label `traefik.swarm.network`,
sinon Traefik en choisit un au hasard.

## Middlewares

| Middleware | Effet                                |
| ---------- | ------------------------------------ |
| `crowdsec` | sur toutes les requêtes : ban et WAF |
| `lan`      | IP privées uniquement                |
| `lan-sso`  | `lan` + Authelia                     |

## SSO

Authelia pour l'authentification, LLDAP pour les comptes et les groupes.

- OIDC quand l'appli le supporte, forward auth (`lan-sso`) sinon.
- 2FA partout : passkey, TOTP ou Duo. Les invités (`friends`) n'ont qu'un mot de
  passe, sur les services qui leur sont ouverts.
- Accès par groupe (`admins`, `famille`, `friends`), une policy par client OIDC.
- Jellyfin s'authentifie directement sur LLDAP. Les invités créent leur compte
  via Wizarr.

## Break-glass

Ce dont dépend le SSO ne dépend pas du SSO : LLDAP (LAN only), OpenBao, l'admin
local de Jellyfin et les managers Swarm restent accessibles sans Authelia.
