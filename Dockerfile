# syntax=docker/dockerfile:1
FROM ubuntu:22.04

# x86_64 | aarch64 | armhf
ARG VERSION=0.9.12.2
ARG ARCH=x86_64

ENV DEBIAN_FRONTEND=noninteractive

# Runtime deps
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        xvfb \
        xauth \
        libx11-6 \
        libxcb1 \
        libxcomposite1 \
        libxcursor1 \
        libxdamage1 \
        libxext6 \
        libxfixes3 \
        libxi6 \
        libxkbcommon0 \
        libxrandr2 \
        libxrender1 \
        libxss1 \
        libxtst6 \
        libatk-bridge2.0-0 \
        libatk1.0-0 \
        libgtk-3-0 \
        libasound2 \
        libgbm1 \
        libcups2 \
        libnss3 \
        libpango-1.0-0 \
        libpangoft2-1.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Extract AppImage (no FUSE in Docker)
RUN set -eux; \
    curl -fSL \
        "https://github.com/ttalvitie/browservice/releases/download/v${VERSION}/browservice-v${VERSION}-${ARCH}.AppImage" \
        -o /tmp/browservice.AppImage; \
    chmod +x /tmp/browservice.AppImage; \
    /tmp/browservice.AppImage --appimage-extract; \
    mv squashfs-root /opt/browservice; \
    rm /tmp/browservice.AppImage

# SUID sandbox
RUN chown root:root /opt/browservice/opt/browservice/chrome-sandbox \
 && chmod 4755      /opt/browservice/opt/browservice/chrome-sandbox

RUN useradd -m -u 1000 -s /bin/bash browservice \
 && mkdir -p /home/browservice/.browservice \
 && chown -R browservice:browservice /home/browservice

USER browservice

EXPOSE 8080

ENTRYPOINT ["/opt/browservice/AppRun"]
CMD ["--vice-opt-http-listen-addr=0.0.0.0:8080", "--chromium-args=no-sandbox"]