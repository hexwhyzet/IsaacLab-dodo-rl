.PHONY: setup train help

ISAACLAB_PATH ?= $(shell pwd)
ISAACSIM_ROOT_PATH ?= /isaac-sim

# ── Setup ─────────────────────────────────────────────────────────────────────

setup:
	$(ISAACLAB_PATH)/setup.sh

# ── Training ──────────────────────────────────────────────────────────────────

train:
	@test -n "$(TASK)" || (echo "Usage: make train TASK=stand_v1" && exit 1)
	WANDB_API_KEY=$(WANDB_API_KEY) $(ISAACLAB_PATH)/isaaclab.sh -p \
		$(ISAACLAB_PATH)/source/dodo_rl/train.py task=$(TASK) $(EXTRA)

# ── Help ──────────────────────────────────────────────────────────────────────

help:
	@echo ""
	@echo "  make setup            Create _isaac_sim symlink and install Isaac Lab"
	@echo "  make train TASK=X     Run training"
	@echo ""
