#!/bin/bash
# Run this ONCE on the host before starting Docker.
# Creates required directories and sets permissions so Django can write files
# that Asterisk inside Docker can read.

set -e

SOUNDS_DIR="${SOUNDS_PATH:-/var/lib/asterisk/sounds/custom}"
MOH_DIR="/var/lib/asterisk/moh"
RECORDINGS_DIR="/var/spool/asterisk/monitor"

echo "==> Creating host directories"
sudo mkdir -p "$SOUNDS_DIR" "$MOH_DIR" "$RECORDINGS_DIR"
sudo chmod 777 "$SOUNDS_DIR" "$MOH_DIR" "$RECORDINGS_DIR"
echo "==> Done. Directories ready:"
ls -la "$SOUNDS_DIR"
