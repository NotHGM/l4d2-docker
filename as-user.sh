#!/bin/bash
# Install steamcmd
set -euo pipefail

# Ensure curl is available
if ! command -v curl >/dev/null 2>&1; then
  echo "curl not available"
  exit 1
fi

mkdir -p .steam/sdk32/

# Download and extract steamcmd only if not present
if [ ! -f ./steamcmd.sh ]; then
  echo "Downloading steamcmd..."
  curl -fsSL https://media.steampowered.com/installer/steamcmd_linux.tar.gz | tar -xzvf -
fi

# Ensure steamcmd exists and is executable
if [ ! -f ./steamcmd.sh ]; then
  echo "steamcmd.sh not found after download"
  exit 1
fi
chmod +x ./steamcmd.sh

# Create steam client symlink only if target exists
if [ -e "$HOME/linux32/steamclient.so" ]; then
  ln -sf "$HOME/linux32/steamclient.so" ~/.steam/sdk32/steamclient.so
fi

# Convenient symlinks for mount points
if [ "${INSTALL_DIR}" = "l4d2" ]; then
    GAME_DIR="${INSTALL_DIR}/left4dead2"
elif [ "${INSTALL_DIR}" = "l4d" ]; then
    GAME_DIR="${INSTALL_DIR}/left4dead"
else
    exit 100
fi

mkdir -p ./"${GAME_DIR}"
ln -s /addons         "./${GAME_DIR}/addons"
ln -s /cfg            "./${GAME_DIR}/cfg"
ln -s /motd/host.txt  "./${GAME_DIR}/myhost.txt"
ln -s /motd/motd.txt  "./${GAME_DIR}/mymotd.txt"

# Install game
echo """force_install_dir "/home/louis/${INSTALL_DIR}"
login anonymous
app_update ${GAME_ID}
quit""" > update.txt
if [ "${INSTALL_DIR}" = "l4d2" ]; then
  # https://github.com/ValveSoftware/steam-for-linux/issues/11522
  echo """force_install_dir "/home/louis/${INSTALL_DIR}"
  login anonymous
  @sSteamCmdForcePlatformType windows
  app_update ${GAME_ID}
  @sSteamCmdForcePlatformType linux
  app_update ${GAME_ID} validate
  quit""" > first-install-l4d2.txt
  ./steamcmd.sh +runscript first-install-l4d2.txt
else
  ./steamcmd.sh +runscript update.txt
fi