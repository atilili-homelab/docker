# Déploiement

`main` est la production : je push, Komodo déploie.

## Du push au conteneur

1. La CI vérifie chaque push sur une branche.
2. Le merge dans `main` déclenche un webhook signé vers la procédure Komodo «
   Deploy on push ».
3. La procédure sync la configuration de Komodo, puis redéploie les stacks
   modifiées (`BatchDeployStackIfChanged`).

Chaque sync ne gère que les ressources qui portent son tag.

## Ce qui déclenche un redeploy

- Un compose modifié.
- Un fichier d'env ou de config, s'il est dans `config_files` avec
  `requires = "Redeploy"`.
- Une config ou un secret Swarm : on change son nom (`_v2`). Les anciennes
  configs se suppriment à la main.

## Rollback

`failure_action: rollback` sur chaque service Swarm. Après un rollback, relancer
un « Deploy » simple : « Deploy if changed » ne voit plus de différence.

En dernier recours, depuis un manager : `docker service rollback <stack>_<service>`.

Éviter de modifier une base et son service dans le même déploiement : le service
peut démarrer avant la base et partir en rollback.

## CI

Forgejo Actions sur un runner self-hosted avec Nix.

| Workflow       | Déclencheur                | Ce qu'il fait                           |
| -------------- | -------------------------- | --------------------------------------- |
| `ci.yml`       | push hors `main`           | gitleaks, pre-commit                    |
| `authelia.yml` | push hors `main`, Authelia | `validate-config` avec l'image déployée |

Les hooks pre-commit tournent aussi en local, dont `docker compose config` sur
chaque stack et Conventional Commits.

## Renovate

- Images pinnées par digest.
- Automerge des minor, patch et digest ; les major attendent une review.
- Trois jours d'attente avant une nouvelle version.
- Les registres sans date de publication (ghcr.io, lscr.io…) passent dans un
  créneau hebdomadaire.
