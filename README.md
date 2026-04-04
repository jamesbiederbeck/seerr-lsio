<p align="center">
<img src="./public/logo_full.svg" alt="Seerr" style="margin: 20px 0;">
</p>

> **⚠️ Disclaimer:** This repository (`seerr-lsio`) is an **unofficial**, community-maintained Docker image packaging for [Seerr](https://github.com/seerr-team/seerr).
> It is **not affiliated with, endorsed by, or supported by** the Seerr project team or [LinuxServer.io](https://www.linuxserver.io/).
> For official support, please visit the upstream projects directly.

<p align="center">
<img src="https://github.com/jamesbiederbeck/seerr-lsio/actions/workflows/release.yml/badge.svg" alt="Release" />
<img src="https://github.com/jamesbiederbeck/seerr-lsio/actions/workflows/ci.yml/badge.svg" alt="CI">
</p>

**Seerr** is a free and open source software application for managing requests for your media library. It integrates with [Jellyfin](https://jellyfin.org), [Plex](https://plex.tv), and [Emby](https://emby.media/), as well as **[Sonarr](https://sonarr.tv/)** and **[Radarr](https://radarr.video/)**.

This repository packages Seerr as an [LSIO-style](https://www.linuxserver.io/) container image built on the LinuxServer.io Alpine base image.

## Getting Started

Pull the image from the [GitHub Container Registry](https://ghcr.io/jamesbiederbeck/seerr-lsio):

```sh
docker pull ghcr.io/jamesbiederbeck/seerr-lsio:latest
```

### Docker Compose

```yaml
---
services:
  seerr:
    image: ghcr.io/jamesbiederbeck/seerr-lsio:latest
    container_name: seerr
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
    volumes:
      - /path/to/appdata/config:/config
    ports:
      - 5055:5055
    restart: unless-stopped
```

For upstream Seerr documentation, see [docs.seerr.dev](https://docs.seerr.dev/getting-started/).

## Features

- Full Jellyfin/Emby/Plex integration including authentication with user import & management.
- Support for **PostgreSQL** and **SQLite** databases.
- Supports Movies, Shows and Mixed Libraries.
- Easy integration with Sonarr and Radarr.
- Customizable request system with a friendly, easy-to-use interface.
- Granular permission system.
- Support for various notification agents.
- Mobile-friendly design.

## Release Process

For information on how releases are built and published, see [docs/release-process.md](./docs/release-process.md).

## License

[MIT](./LICENSE)
