# Isaac Lab — заметки

## GUI на удалённой машине (vast.ai)

Isaac Sim поддерживает WebRTC стриминг через `--livestream`.

| Значение | Описание |
|----------|----------|
| `--livestream 1` | WebRTC + явно прописывает публичный IP и порт 49100 (для vast.ai) |
| `--livestream 2` | WebRTC без привязки к IP (LAN / приватная сеть) |

На vast.ai проброшен порт `49100 -> tcp`. Используем `--livestream 1` с публичным IP:

```bash
LIVESTREAM_PUBLIC_IP=80.124.38.40 ./isaaclab.sh -p scripts/reinforcement_learning/rsl_rl/train.py \
  --task Isaac-Velocity-Flat-Cassie-v0 \
  --num_envs 2048 \
  --livestream 1 \
  --video \
  --video_length 200 \
  --video_interval 200
```

Подключение — **Omniverse Streaming Client** → `80.124.38.40:49100`.

Источник: `source/isaaclab/isaaclab/app/app_launcher.py`, строка 115.
