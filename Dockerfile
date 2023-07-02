# https://hub.docker.com/_/debian
FROM debian:bookworm-slim

LABEL org.opencontainers.image.title="SVG file validator"

ARG LC_ALL="C.UTF-8"
ARG TERM="linux"
ARG DEBIAN_FRONTEND="noninteractive"

RUN set -e -x \
    && apt-get update \
    && apt-get install -y wget xmlstarlet libxml2-utils \
    && apt-get autoremove --purge -y \
    && apt-get clean \
    && rm -r /var/lib/apt/lists/*

# https://www.w3.org/2012/04/XMLSchema.xsd
COPY XMLSchema.xsd /usr/local/share/xml/XMLSchema.xsd
# https://github.com/oreillymedia/HTMLBook/tree/master/schema/svg
COPY xml.xsd /usr/local/share/xml/xml.xsd
COPY xlink.xsd /usr/local/share/xml/xlink.xsd
COPY SVG.xsd /usr/local/share/xml/SVG.xsd
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
