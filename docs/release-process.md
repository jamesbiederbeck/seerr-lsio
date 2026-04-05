# Release Process

This document describes how releases are published for `seerr-lsio`.

## Overview

`seerr-lsio` is an unofficial Docker image packaging of [Seerr](https://github.com/seerr-team/seerr) using the [LinuxServer.io](https://www.linuxserver.io/) base image stack. Releases are versioned and published to the [GitHub Container Registry (GHCR)](https://ghcr.io/jamesbiederbeck/seerr-lsio).

## Branches

| Branch    | Purpose                                                             |
|-----------|---------------------------------------------------------------------|
| `develop` | Integration branch; Docker images tagged `:develop` are published on every merge |

## Versioning

Image versions follow a four-part scheme: `vMAJOR.MINOR.PATCH.MICRO`

- `MAJOR.MINOR.PATCH` — mirrors the upstream [Seerr](https://github.com/seerr-team/seerr) release version
- `MICRO` — image revision counter, incremented for packaging-only changes against the same upstream version; reset to `0` when the upstream version changes

Both values are tracked in `package_versions.txt`:

| Variable          | Description                                            |
|-------------------|--------------------------------------------------------|
| `SEERR_VERSION`   | Upstream Seerr version being packaged (e.g. `1.2.3`)  |
| `IMAGE_REVISION`  | Image revision for this upstream version (e.g. `0`)   |

**Example tags:** `v1.2.3.0` (initial packaging of Seerr 1.2.3), `v1.2.3.1` (packaging fix, same upstream)

## Release Workflow

### 1. Update version pins

Edit `package_versions.txt` and set the appropriate values:

- **Tracking a new upstream Seerr release:** bump `SEERR_VERSION` to match the upstream tag, reset `IMAGE_REVISION` to `0`
- **Packaging-only fix (no upstream change):** increment `IMAGE_REVISION`

Commit and merge the change into `develop`.

### 2. Create a tag

Run the **Create tag** workflow (`create-tag.yml`) manually from the [GitHub Actions](../../actions/workflows/create-tag.yml) tab on the `develop` branch. This workflow:

1. Reads `SEERR_VERSION` and `IMAGE_REVISION` from `package_versions.txt`
2. Composes the tag as `v${SEERR_VERSION}.${IMAGE_REVISION}`
3. Writes the version to `package.json`
4. Commits and pushes the version bump to `develop`
5. Creates and pushes the version tag (e.g. `v1.2.3.0`)

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

- `ghcr.io/jamesbiederbeck/seerr-lsio:<version>` — e.g. `v1.2.3.0`
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

The `package_versions.txt` file in the repository root controls all version pins used in the Docker build:

| Variable            | Description                                            |
|---------------------|--------------------------------------------------------|
| `SEERR_VERSION`     | Upstream Seerr version being packaged                  |
| `IMAGE_REVISION`    | Image revision for this upstream version               |
| `BASEIMAGE_VERSION` | LinuxServer.io Alpine base image version               |
| `NODE_VERSION`      | Node.js version pinned in Alpine APK                   |
