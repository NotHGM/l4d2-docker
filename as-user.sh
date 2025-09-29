#!/bin/bash
# Install steamcmd
set -euo pipefail

# Ensure curl is available
if ! command -v curl >/dev/null 2>&1; then
  echo "curl not available"
  exit 1
fi

# Detect architecture and skip SteamCMD on unsupported arches (e.g., aarch64)
ARCH=$(uname -m || echo unknown)
if [ "${ARCH}" = "aarch64" ] || [ "${ARCH}" = "arm64" ]; then
  echo "Detected architecture ${ARCH} - SteamCMD x86 binary will not run. Skipping SteamCMD steps."
  # Still create expected directories and symlinks for volume mounts
  mkdir -p "$HOME/linux32" || true
  mkdir -p .steam/sdk32/ || true
  # Create mountpoint directories for later runtime use
  if [ "${INSTALL_DIR}" = "l4d2" ]; then
    GAME_DIR="${INSTALL_DIR}/left4dead2"
  elif [ "${INSTALL_DIR}" = "l4d" ]; then
    GAME_DIR="${INSTALL_DIR}/left4dead"
  else
    exit 100
  fi
  mkdir -p "./${GAME_DIR}" || true
  ln -sf /addons "./${GAME_DIR}/addons" || true
  ln -sf /cfg "./${GAME_DIR}/cfg" || true
  ln -sf /motd/host.txt "./${GAME_DIR}/myhost.txt" || true
  ln -sf /motd/motd.txt "./${GAME_DIR}/mymotd.txt" || true
  exit 0
fi

mkdir -p .steam/sdk32/

# Download and extract steamcmd only if not present
if [ ! -f ./steamcmd.sh ]; then
  echo "Downloading steamcmd..."
  mkdir -p "$HOME/linux32"
  # Extract into $HOME so the expected path /home/louis/linux32/steamcmd exists
  curl -fsSL https://media.steampowered.com/installer/steamcmd_linux.tar.gz | tar -xzvf - -C "$HOME"
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

# Verify steamcmd binary exists where steamcmd.sh expects it
if [ ! -x "$HOME/linux32/steamcmd" ]; then
  echo "steamcmd binary not found or not executable at $HOME/linux32/steamcmd"
  echo "Listing $HOME contents for debugging:"
  ls -l "$HOME" || true
  ls -l "$HOME/linux32" || true
  exit 1
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