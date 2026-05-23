.PHONY: setup train train-gui play help

ISAACLAB_PATH ?= $(shell pwd)

TASK        ?= Isaac-Velocity-Flat-Dodo-v0
NUM_ENVS    ?= 2048
ITERATIONS  ?= 1500

# Video: запись каждые VIDEO_INTERVAL шагов, длиной VIDEO_LENGTH шагов
VIDEO_LENGTH   ?= 200
VIDEO_INTERVAL ?= 500

# Livestream: 1 = WebRTC + публичный IP (vast.ai), 2 = LAN. Не передаём 0.
LIVESTREAM_PUBLIC_IP ?=
LIVESTREAM  ?=

# Флаг --livestream добавляется только если LIVESTREAM задан и не пустой
_LIVESTREAM_FLAG = $(if $(LIVESTREAM),--livestream $(LIVESTREAM),)

TRAIN_SCRIPT := $(ISAACLAB_PATH)/scripts/reinforcement_learning/rsl_rl/train.py
PLAY_SCRIPT  := $(ISAACLAB_PATH)/scripts/reinforcement_learning/rsl_rl/play.py

# ── Setup ─────────────────────────────────────────────────────────────────────

setup:
	ISAACLAB_PATH=$(ISAACLAB_PATH) $(ISAACLAB_PATH)/setup.sh

# ── Training ──────────────────────────────────────────────────────────────────

# Headless + видео (offscreen rendering)
train:
	$(ISAACLAB_PATH)/isaaclab.sh -p $(TRAIN_SCRIPT) \
		--task $(TASK) \
		--num_envs $(NUM_ENVS) \
		--max_iterations $(ITERATIONS) \
		--video \
		--video_length $(VIDEO_LENGTH) \
		--video_interval $(VIDEO_INTERVAL) \
		--headless

# С GUI/livestream + видео
train-gui:
	LIVESTREAM_PUBLIC_IP=$(LIVESTREAM_PUBLIC_IP) \
	$(ISAACLAB_PATH)/isaaclab.sh -p $(TRAIN_SCRIPT) \
		--task $(TASK) \
		--num_envs $(NUM_ENVS) \
		--max_iterations $(ITERATIONS) \
		--video \
		--video_length $(VIDEO_LENGTH) \
		--video_interval $(VIDEO_INTERVAL) \
		$(_LIVESTREAM_FLAG)

# ── Play (inference) ──────────────────────────────────────────────────────────

play:
	LIVESTREAM_PUBLIC_IP=$(LIVESTREAM_PUBLIC_IP) \
	$(ISAACLAB_PATH)/isaaclab.sh -p $(PLAY_SCRIPT) \
		--task $(TASK:-v0=-Play-v0) \
		--num_envs 50 \
		$(_LIVESTREAM_FLAG)

# ── Help ──────────────────────────────────────────────────────────────────────

help:
	@echo ""
	@echo "  make setup                       Создать симлинк и скачать ассеты"
	@echo ""
	@echo "  make train                       Headless + запись видео (offscreen)"
	@echo "  make train-gui                   С GUI/livestream + видео"
	@echo "  make play                        Inference по последнему чекпойнту"
	@echo ""
	@echo "  Параметры:"
	@echo "    TASK=$(TASK)"
	@echo "    NUM_ENVS=$(NUM_ENVS)"
	@echo "    ITERATIONS=$(ITERATIONS)"
	@echo "    VIDEO_LENGTH=$(VIDEO_LENGTH)        шагов на видео"
	@echo "    VIDEO_INTERVAL=$(VIDEO_INTERVAL)       шагов между записями"
	@echo "    LIVESTREAM=1                     WebRTC + публичный IP (vast.ai)"
	@echo "    LIVESTREAM=2                     WebRTC LAN"
	@echo "    LIVESTREAM_PUBLIC_IP=<ip>        IP машины (для LIVESTREAM=1)"
	@echo ""
	@echo "  Примеры:"
	@echo "    make train NUM_ENVS=4096"
	@echo "    make train-gui LIVESTREAM=1 LIVESTREAM_PUBLIC_IP=80.124.38.40"
	@echo "    make play LIVESTREAM=1 LIVESTREAM_PUBLIC_IP=80.124.38.40"
	@echo ""
