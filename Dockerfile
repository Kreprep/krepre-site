# syntax=docker/dockerfile:1
FROM alpine:3.24 AS build
# hugo.toml sets timeZone, and alpine ships without the time zone database
RUN apk add --no-cache tzdata
ARG HUGO_VERSION=0.170.0
ADD --checksum=sha256:0930754ec22ad2dd1a252f8c31a5e57faccc9d15f1c3d381ddafcb96eeb8aef0 \
    https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_linux-amd64.tar.gz /tmp/hugo.tar.gz
RUN tar -xzf /tmp/hugo.tar.gz -C /usr/local/bin hugo
WORKDIR /src
COPY . .
RUN hugo --gc --minify

FROM caddy:2.11.9-alpine
# Links the GHCR package to the repo so the workflow token can push to it
LABEL org.opencontainers.image.source=https://github.com/Kreprep/krepre-site
COPY Caddyfile /etc/caddy/Caddyfile
COPY --from=build /src/public /srv
