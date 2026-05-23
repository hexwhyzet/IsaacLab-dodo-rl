#!/bin/bash
set -e

echo "[INFO] Creating _isaac_sim symlink..."
ln -sf /isaac-sim "${ISAACLAB_PATH}/_isaac_sim"

# ---------------------------------------------------------------------------
# Download Dodo (dodo_daimao) robot assets from HuggingFace
# Repo: https://huggingface.co/ultravanish/dodo-rl-checkpoints
# ---------------------------------------------------------------------------
HF_REPO="https://huggingface.co/ultravanish/dodo-rl-checkpoints/resolve/main"
ASSET_DIR="${ISAACLAB_PATH}/source/isaaclab_assets/data/Robots/Dodo"

_hf_download() {
    local src="$1"
    local dst="$2"
    if [ -f "${dst}" ]; then
        echo "[SKIP] $(basename ${dst}) already exists"
    else
        echo "[DOWN] $(basename ${dst})"
        wget -q --show-progress --continue -O "${dst}" "${src}"
    fi
}

# USD files (used by Isaac Lab)
echo "[INFO] Downloading Dodo USD assets..."
mkdir -p "${ASSET_DIR}/configuration"
_hf_download "${HF_REPO}/usd/dodo_ROS.usd"                                   "${ASSET_DIR}/dodo_ROS.usd"
_hf_download "${HF_REPO}/usd/configuration/dodo_ROS_base.usd"                "${ASSET_DIR}/configuration/dodo_ROS_base.usd"
_hf_download "${HF_REPO}/usd/configuration/dodo_ROS_physics.usd"             "${ASSET_DIR}/configuration/dodo_ROS_physics.usd"
_hf_download "${HF_REPO}/usd/configuration/dodo_ROS_robot.usd"               "${ASSET_DIR}/configuration/dodo_ROS_robot.usd"
_hf_download "${HF_REPO}/usd/configuration/dodo_ROS_sensor.usd"              "${ASSET_DIR}/configuration/dodo_ROS_sensor.usd"
_hf_download "${HF_REPO}/usd/configuration/dodo_simple_ROS_base.usd"         "${ASSET_DIR}/configuration/dodo_simple_ROS_base.usd"
_hf_download "${HF_REPO}/usd/configuration/dodo_simple_ROS_physics.usd"      "${ASSET_DIR}/configuration/dodo_simple_ROS_physics.usd"
_hf_download "${HF_REPO}/usd/configuration/dodo_simple_ROS_robot.usd"        "${ASSET_DIR}/configuration/dodo_simple_ROS_robot.usd"
_hf_download "${HF_REPO}/usd/configuration/dodo_simple_ROS_sensor.usd"       "${ASSET_DIR}/configuration/dodo_simple_ROS_sensor.usd"

# Mesh files (STL, reference only — already embedded in USD)
echo "[INFO] Downloading Dodo mesh assets..."
mkdir -p "${ASSET_DIR}/meshes"
for mesh in body hip_left hip_right upper_leg_left upper_leg_right \
            lower_leg_left lower_leg_right foot_left foot_right \
            foot_sole_left foot_sole_right; do
    _hf_download "${HF_REPO}/meshes/${mesh}.STL" "${ASSET_DIR}/meshes/${mesh}.STL"
done

# URDF & CSV (robot description, used as reference for joint parameters)
echo "[INFO] Downloading Dodo URDF assets..."
mkdir -p "${ASSET_DIR}/urdf"
_hf_download "${HF_REPO}/urdf/dodo_daimao.urdf" "${ASSET_DIR}/urdf/dodo_daimao.urdf"
_hf_download "${HF_REPO}/urdf/dodo_daimao.csv"  "${ASSET_DIR}/urdf/dodo_daimao.csv"

# Config (joint order for the controller)
echo "[INFO] Downloading Dodo config assets..."
mkdir -p "${ASSET_DIR}/config"
_hf_download "${HF_REPO}/config/joint_names_dodo_daimao.yaml" "${ASSET_DIR}/config/joint_names_dodo_daimao.yaml"

echo "[INFO] All Dodo assets saved to ${ASSET_DIR}"
echo "[INFO] Done. Run '${ISAACLAB_PATH}/isaaclab.sh --install' to install extensions."
