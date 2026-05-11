#!/bin/bash
set -e

echo "[INFO] Creating _isaac_sim symlink..."
ln -sf /isaac-sim "${ISAACLAB_PATH}/_isaac_sim"

echo "[INFO] Done. Run '${ISAACLAB_PATH}/isaaclab.sh --install' to install extensions."
