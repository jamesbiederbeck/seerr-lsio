## Build stage: compile Seerr from source
ARG BASEIMAGE_VERSION=3.21
ARG NODE_VERSION=22.22.1

FROM node:${NODE_VERSION}-alpine3.22@sha256:9f96f09f127f06feaff1e7faa4a34a3020cf5c1138c988782e59959641facabe AS build

ARG TARGETPLATFORM
ENV TARGETPLATFORM=${TARGETPLATFORM:-linux/amd64}
ARG COMMIT_TAG
ENV COMMIT_TAG=${COMMIT_TAG}

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

RUN \
  case "${TARGETPLATFORM}" in \
  'linux/arm64' | 'linux/arm/v7') \
  apk update && \
  apk add --no-cache python3 make g++ gcc libc6-compat bash && \
  npm install --global node-gyp \
  ;; \
  esac

WORKDIR /app

COPY . .

RUN --mount=type=cache,id=pnpm,target=/pnpm/store CYPRESS_INSTALL_BINARY=0 pnpm install --frozen-lockfile

RUN pnpm build

RUN rm -rf .next/cache

RUN --mount=type=cache,id=pnpm,target=/pnpm/store CI=true pnpm install --prod --frozen-lockfile

## Final stage: LSIO base image with compiled Seerr
FROM ghcr.io/linuxserver/baseimage-alpine:${BASEIMAGE_VERSION}

ARG BASEIMAGE_VERSION=3.21
ARG NODE_VERSION=22.22.1
ARG COMMIT_TAG
ENV COMMIT_TAG=${COMMIT_TAG}

LABEL org.opencontainers.image.title="Seerr" \
      org.opencontainers.image.description="Free and open source software application for managing requests for your media library" \
      org.opencontainers.image.source="https://github.com/jamesbiederbeck/seerr-lsio" \
      org.opencontainers.image.licenses="MIT"

ENV APP_NAME="seerr"

RUN apk add --no-cache \
  "nodejs=${NODE_VERSION}-r0" \
  npm \
  curl \
  bash \
  sqlite \
  tzdata

WORKDIR /app

COPY root/ /

COPY --from=build /app/node_modules /app/seerr/node_modules
COPY --from=build /app/.next /app/seerr/.next
COPY --from=build /app/dist /app/seerr/dist
COPY --from=build /app/public /app/seerr/public
COPY --from=build /app/package.json /app/seerr/package.json

RUN echo "{\"commitTag\": \"${COMMIT_TAG}\"}" > /app/seerr/committag.json

EXPOSE 5055

STOPSIGNAL SIGTERM

VOLUME /config

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD curl --fail http://localhost:5055/api/v1/status || exit 1
