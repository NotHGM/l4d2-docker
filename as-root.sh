#!/bin/bash
ARCH=$(uname -m || true)
if [ "${ARCH}" = "x86_64" ] || [ "${ARCH}" = "amd64" ]; then
    # On x86_64 install 32-bit compat libs for SteamCMD
    microdnf -y install SDL2.i686 \
        libcurl.i686 \
        glibc-langpack-en \
        tar \
        telnet \
        curl \
        ca-certificates
else
    # On non-x86 (e.g., arm64) install native packages
    microdnf -y install SDL2 \
        libcurl \
        glibc-langpack-en \
        tar \
        telnet \
        curl \
        ca-certificates
fi
microdnf -y update || true
microdnf clean all || true

useradd louis

mkdir             /addons /cfg /motd /tmp/dumps
chown louis:louis /addons /cfg /motd /tmp/dumps