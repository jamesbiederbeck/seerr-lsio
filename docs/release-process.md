# Release Process

This document describes how releases are published for `seerr-lsio`.

## Overview

`seerr-lsio` is an unofficial Docker image packaging of [Seerr](https://github.com/seerr-team/seerr) using the [LinuxServer.io](https://www.linuxserver.io/) base image stack. Releases are versioned and published to the [GitHub Container Registry (GHCR)](https://ghcr.io/jamesbiederbeck/seerr-lsio).

## Branches

| Branch    | Purpose                                                             |
|-----------|---------------------------------------------------------------------|
| `main`    | Stable releases only                                                |
| `develop` | Integration branch; Docker images tagged `:develop` are published on every merge |

## Release Workflow

Releases follow [Semantic Versioning](https://semver.org/) and are triggered automatically when a version tag is pushed to `main`.

### 1. Merge changes into `main`

Ensure all desired changes are merged into the `main` branch.

### 2. Create a tag

Run the **Create tag** workflow (`create-tag.yml`) manually from the [GitHub Actions](../../actions/workflows/create-tag.yml) tab. This workflow:

1. Determines the next semantic version from commit history using [`git-cliff`](https://git-cliff.org/)
2. Bumps the version in `package.json`
3. Commits and pushes the version bump to `main`
4. Creates and pushes the version tag (e.g. `v1.2.3`)

### 3. Automated release pipeline

Pushing a `v*` tag triggers the **Seerr Release** workflow (`release.yml`) automatically:

| Step               | Description                                                              |
|--------------------|--------------------------------------------------------------------------|
| **Changelog**      | Generates release notes from commit history using `git-cliff`            |
| **Draft release**  | Creates a GitHub draft release with the generated changelog              |
| **Build**          | Builds the Docker image for `linux/amd64` and `linux/arm64` in parallel  |
| **Publish**        | Pushes a multi-arch manifest to GHCR; tags `:latest` for stable releases |
| **Publish release**| Promotes the draft GitHub release to published                           |

Published image tags:

- `ghcr.io/jamesbiederbeck/seerr-lsio:<version>` — e.g. `v1.2.3`
- `ghcr.io/jamesbiederbeck/seerr-lsio:latest` — stable releases only (no `-` in version)

## Preview Releases

To publish a preview image for testing without a full release, push a tag of the form `preview-<version>`:

```sh
git tag preview-1.2.3-rc1
git push origin preview-1.2.3-rc1
```

This triggers the **Seerr Preview** workflow and pushes `ghcr.io/jamesbiederbeck/seerr-lsio:preview-1.2.3-rc1` to GHCR.

## Develop Builds

Every merge to `develop` triggers a Docker build and push of:

- `ghcr.io/jamesbiederbeck/seerr-lsio:develop`
- `ghcr.io/jamesbiederbeck/seerr-lsio:sha-<commit>`

These are suitable for testing but are not intended for production use.

## Image Version Pins

The `package_versions.txt` file in the repository root controls which base image and Node.js versions are used in the Docker build:

| Variable            | Description                              |
|---------------------|------------------------------------------|
| `BASEIMAGE_VERSION` | LinuxServer.io Alpine base image version |
| `NODE_VERSION`      | Node.js version pinned in Alpine APK     |

Update these values when you want to upgrade the base image or Node.js version.
