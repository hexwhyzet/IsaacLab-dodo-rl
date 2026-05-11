# Docker Setup

## Build and push

```bash
docker build -f setup/Dockerfile -t ultravanish/dodo-rl-isaaclab:latest .
docker push ultravanish/dodo-rl-isaaclab:latest
```

## Run

```bash
docker run --rm -it \
  -e ACCEPT_EULA=Y \
  -e WANDB_API_KEY=<your_key> \
  --runtime=nvidia \
  --ipc=host \
  --ulimit memlock=-1 \
  --ulimit stack=67108864 \
  -v ~/.ssh:/root/.ssh \
  -v /workspace:/workspace \
  ultravanish/dodo-rl-isaaclab:latest bash
```
