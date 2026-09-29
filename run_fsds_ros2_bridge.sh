#!/usr/bin/env bash
# Startet den FSDS ROS2-Bridge-Container.
# Voraussetzung: Dockerfile.fsds-ros2-humble wurde bereits gebaut, z.B.:
#   docker build -t fsds-ros2-humble -f Dockerfile.fsds-ros2-humble .

set -euo pipefail

REPO_DIR="${HOME}/Formula-Student-Driverless-Simulator"

if [ ! -d "${REPO_DIR}/ros2" ]; then
  echo "Fehler: ${REPO_DIR}/ros2 nicht gefunden. Repo korrekt geklont?"
  exit 1
fi

docker run -it --rm \
  --network=host \
  -v "${REPO_DIR}:/root/Formula-Student-Driverless-Simulator" \
  -e DISPLAY="${DISPLAY:-}" \
  -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
  --name fsds-ros2-bridge \
  fsds-ros2-humble
