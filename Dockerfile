FROM rockylinux/rockylinux:9-minimal AS base

ADD as-root.sh .
# Ensure the script is executable before running to avoid permission denied during build
RUN chmod +x ./as-root.sh && ./as-root.sh

WORKDIR /home/louis
USER louis

FROM base AS game

ARG GAME_ID=222860 \
    INSTALL_DIR="l4d2" \
    DEFAULT_MAP="c14m1_junkyard" \
    SERVER_DIR_ARG="/home/louis/l4d2"

EXPOSE 27015/tcp 27015/udp

USER root
ADD as-user.sh .
# Ensure the user script is executable (do this as root so chmod succeeds)
RUN chmod +x ./as-user.sh

# Pre-install SteamCMD into /home/louis only on amd64 so the steam binary and steamcmd.sh exist
# If building for arm64 we skip extracting the x86 SteamCMD archive (it won't run on arm64).
ARG TARGETARCH
RUN if [ "${TARGETARCH}" = "amd64" ] || [ "${TARGETARCH}" = "x86_64" ]; then \
            mkdir -p /home/louis/linux32 && \
            curl -fsSL https://media.steampowered.com/installer/steamcmd_linux.tar.gz | tar -xzvf - -C /home/louis && \
            chown -R louis:louis /home/louis/linux32 /home/louis/steamcmd.sh || true && \
            chmod +x /home/louis/steamcmd.sh /home/louis/linux32/steamcmd || true; \
        else \
            echo "Skipping SteamCMD extraction for architecture ${TARGETARCH}"; \
        fi

# Run installation steps as the non-root user so paths like ~ expand to /home/louis
USER louis
RUN ./as-user.sh

USER root
VOLUME ["/addons", "/cfg"]

ENV DEFAULT_MAP=$DEFAULT_MAP \
    DEFAULT_MODE="coop" \
    PORT=0 \
    HOSTNAME="Left4DevOps" \
    REGION=255 \
    GAME_ID=$GAME_ID \
    INSTALL_DIR=$INSTALL_DIR \
    SERVER_DIR=$SERVER_DIR_ARG \
    STEAM_GROUP=0 \
    HOST_CONTENT="" \
    MOTD_CONTENT="Play nice, kill zombies" \
    MOTD=0

ADD entrypoint.sh .
# Ensure entrypoint is executable
RUN chmod +x ./entrypoint.sh
USER louis
ENTRYPOINT ["./entrypoint.sh"]
