# StormDesk — Remote Desktop by Stormeo

**StormDesk** est un fork de [RustDesk](https://github.com/rustdesk/rustdesk), pré-configuré pour se connecter automatiquement au relay self-hosted `relay.stormeo.io`.

Les clients Stormeo téléchargent StormDesk, le lancent — et un ID à 9 chiffres s'affiche immédiatement. **Zéro configuration manuelle** (pas de Settings → Network à remplir).

## Différences avec RustDesk vanilla

| | RustDesk | StormDesk |
|--|---------|-----------|
| **Relay** | Public `rs-ny.rustdesk.com` | `relay.stormeo.io` (self-hosted) |
| **Clé publique** | Clé RustDesk | Clé ed25519 Stormeo |
| **Nom** | RustDesk | StormDesk |
| **Icône** | Logo RustDesk | Logo Stormeo (à venir) |
| **Config nécessaire** | Settings → Network → Custom | Aucune |

## Téléchargement

Rendez-vous sur la [page Releases](https://github.com/stormeoio/stormdesk/releases) ou sur votre espace Stormeo → `/stormeo-remote`.

## Build

Ce fork utilise le même système de build que RustDesk. Voir la [documentation officielle](https://rustdesk.com/docs/en/dev/build/).

```bash
# Déclencher un build via tag
git tag v1.0.0
git push origin v1.0.0
# → GitHub Actions build automatiquement Windows + macOS
```

## Licence

Ce fork est distribué sous **AGPL-3.0**, conformément à la licence originale de RustDesk.

- Code source original : [rustdesk/rustdesk](https://github.com/rustdesk/rustdesk) © Purslane Ltd.
- Modifications Stormeo : © 2026 Stormeo
- Toutes les modifications sont publiées sous AGPL-3.0

Voir [LICENSE](LICENSE) pour le texte complet.
