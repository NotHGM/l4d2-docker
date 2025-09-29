#!/bin/bash
microdnf -y install SDL2.i686 \
    libcurl.i686 \
    glibc-langpack-en \
    tar \
    telnet \
    curl \
    ca-certificates
microdnf -y update
microdnf clean all

useradd louis

mkdir             /addons /cfg /motd /tmp/dumps
chown louis:louis /addons /cfg /motd /tmp/dumps