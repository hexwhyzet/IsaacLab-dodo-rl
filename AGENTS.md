# Isaac Lab — краткое описание для агентов

## Что это

[Isaac Lab](https://github.com/isaac-sim/IsaacLab) — фреймворк для обучения роботов методами reinforcement learning на базе NVIDIA Isaac Sim / PhysX. Поддерживает множество RL-библиотек; основной фокус в этом проекте — **RSL-RL**.

---

## Структура репозитория

```
source/
  isaaclab/          # Ядро: среды, сенсоры, сцены, актуаторы, менеджеры
  isaaclab_assets/   # USD-модели роботов (Cassie, Spot, H1, ...)
  isaaclab_tasks/    # Готовые задачи RL (manager_based/, direct/)
  isaaclab_rl/       # Интеграции RL-библиотек
    isaaclab_rl/rsl_rl/   # RSL-RL: wrapper, конфиги, экспорт
  isaaclab_mimic/    # Imitation learning / data generation
  isaaclab_contrib/  # Контрибуции (дополнительные актуаторы, сенсоры)

scripts/
  reinforcement_learning/rsl_rl/   # train.py, play.py, cli_args.py
  tutorials/         # Примеры 00_sim … 05_controllers
  demos/             # Демо сцен и сенсоров
```

---

## RSL-RL интеграция

### Ключевые файлы

| Файл | Роль |
|------|------|
| `scripts/reinforcement_learning/rsl_rl/train.py` | Точка входа обучения. Парсит аргументы, создаёт среду через `gym.make`, оборачивает в `RslRlVecEnvWrapper`, запускает `OnPolicyRunner` или `DistillationRunner`. |
| `scripts/reinforcement_learning/rsl_rl/play.py` | Воспроизведение чекпойнта. Загружает модель, экспортирует в `.pt`/`.onnx`, гоняет inference-loop. |
| `source/isaaclab_rl/isaaclab_rl/rsl_rl/vecenv_wrapper.py` | `RslRlVecEnvWrapper` — адаптирует Isaac Lab env к интерфейсу `rsl_rl.VecEnv`. Obs конвертируются в `TensorDict`, обрабатываются `dones` и `time_outs`. |
| `source/isaaclab_rl/isaaclab_rl/rsl_rl/rl_cfg.py` | Конфиг-датаклассы: `RslRlOnPolicyRunnerCfg`, `RslRlPpoAlgorithmCfg`, `RslRlMLPModelCfg`, `RslRlRNNModelCfg`. |
| `source/isaaclab_rl/isaaclab_rl/rsl_rl/distillation_cfg.py` | Конфиги дистилляции (teacher → student). |
| `source/isaaclab_rl/isaaclab_rl/rsl_rl/rnd_cfg.py` | Random Network Distillation (curiosity-driven exploration). |
| `source/isaaclab_rl/isaaclab_rl/rsl_rl/symmetry_cfg.py` | Symmetry regularization. |
| `source/isaaclab_rl/isaaclab_rl/rsl_rl/exporter.py` | Экспорт политики в TorchScript JIT и ONNX. |

### Поток данных при обучении

```
train.py
  └── gym.make(task, cfg=env_cfg)       # ManagerBasedRLEnv или DirectRLEnv
       └── RslRlVecEnvWrapper            # obs → TensorDict, clip_actions
            └── OnPolicyRunner (PPO)    # из rsl-rl-lib >= 3.0.1
                 └── runner.learn(max_iterations)
```

### Конфиг агента (схема)

```python
RslRlOnPolicyRunnerCfg(
    actor=RslRlMLPModelCfg(hidden_dims=[512, 256, 128], activation="elu"),
    critic=RslRlMLPModelCfg(hidden_dims=[512, 256, 128], activation="elu"),
    algorithm=RslRlPpoAlgorithmCfg(
        learning_rate=1e-3, gamma=0.99, lam=0.95,
        num_learning_epochs=5, num_mini_batches=4,
        entropy_coef=0.01, clip_param=0.2,
    ),
    obs_groups={"actor": ["policy"], "critic": ["policy", "privileged"]},
    max_iterations=1500,
    save_interval=50,
    logger="tensorboard",  # или "wandb", "neptune"
)
```

Конфиги задач регистрируются через entry point `rsl_rl_cfg_entry_point` в `pyproject.toml` каждого пакета задач.

### Запуск обучения (vast.ai / remote)

```bash
# С GUI через WebRTC (livestream 1 = публичный IP + порт 49100)
LIVESTREAM_PUBLIC_IP=<ip> ./isaaclab.sh -p scripts/reinforcement_learning/rsl_rl/train.py \
  --task Isaac-Velocity-Flat-Cassie-v0 \
  --num_envs 2048 \
  --livestream 1

# Headless (без GUI)
./isaaclab.sh -p scripts/reinforcement_learning/rsl_rl/train.py \
  --task Isaac-Velocity-Flat-Cassie-v0 \
  --num_envs 4096 \
  --headless
```

Логи и чекпойнты сохраняются в `logs/rsl_rl/<experiment_name>/<timestamp>/`.

---

## Где искать задачи

- `source/isaaclab_tasks/isaaclab_tasks/manager_based/` — задачи на базе менеджеров (locomotion, manipulation)
- `source/isaaclab_tasks/isaaclab_tasks/direct/` — задачи с прямым API
- Конфиги RSL-RL для каждой задачи лежат рядом с задачей в файле `*_rsl_rl_cfg.py` или `agents/`

## Роботы в проекте

### Dodo (dodo_daimao)

URDF/USD источник: https://huggingface.co/ultravanish/dodo-rl-checkpoints

**USD-ассеты** в `source/isaaclab_assets/data/Robots/Dodo/`:
```
dodo_ROS.usd                    ← главный USD (точка входа для DODO_CFG)
configuration/
  dodo_simple_ROS_robot.usd     ← упрощённая геометрия (для DODO_SIMPLE_CFG)
  dodo_ROS_physics.usd / *_base / *_sensor / ...
```

**Python-конфиг**: `source/isaaclab_assets/isaaclab_assets/robots/dodo.py`
Экспортируется как `DODO_CFG` и `DODO_SIMPLE_CFG`.

**Структура робота** (из dodo_daimao.urdf):
- Масса тела: 3.31 кг; масса бедра: 0.14 кг; голень: 0.073 кг
- 8 приводных revolute-суставов (4 на ногу) + 2 фиксированных (foot_sole)

| Сустав | Ось | Диапазон (рад) | Усилие (Нм) | Скорость (рад/с) |
|--------|-----|----------------|-------------|------------------|
| `hip_left/right` | X | ±0.35 | 27 | 6 |
| `upper_leg_left/right` | Y | ±1.57 | 27 | 6 |
| `lower_leg_left/right` | Y | −3.14 … 1.40 | 9 | 6 |
| `foot_left/right` | Y | −1.05 … 1.57 | 9 | 6 |
| `foot_sole_left/right` | — | fixed | — | — |

**Кинематическая цепочка**:
```
body
├── hip_right → upper_leg_right → lower_leg_right → foot_right → foot_sole_right (fixed)
└── hip_left  → upper_leg_left  → lower_leg_left  → foot_left  → foot_sole_left  (fixed)
```

**Порядок суставов в контроллере** (из joint_names_dodo_daimao.yaml, индекс 0 — пустой):
```
['', 'hip_right', 'upper_leg_right', 'lower_leg_right', 'foot_right',
      'hip_left',  'upper_leg_left',  'lower_leg_left',  'foot_left']
```

---

## Зависимости

- `rsl-rl-lib >= 3.0.1` (используется `OnPolicyRunner`, `DistillationRunner`)
- Isaac Sim / Omniverse (запускается через `isaaclab.sh`)
- `gymnasium`, `torch`, `tensordict`
