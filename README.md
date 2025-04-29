# ComfyUI + Caddy Server (RunPod Optimized)

Run your own secure ComfyUI server with BasicAuth, built on top of RunPod's Pytorch 2.1 GPU image.

## Features
- ComfyUI backend ready-to-run
- Caddy reverse proxy for secure access
- HTTP Basic Authentication with username and password
- Environment variables to control auth
- Auto-start scripts for server management

## Usage

- **Build Image**:

```bash
docker build -t comfyui-server-docker .


## Run Container:

docker run -d \
  -p 80:80 -p 443:443 -p 8188:8188 \
  -v /your/local/models:/workspace/models \
  -e CADDY_USERNAME=yourusername \
  -e CADDY_PASSWORD=yourpassword \
  --name comfyui-server \
  comfyui-server-docker

## Environment Variables:
- CADDY_USERNAME (default: admin)
- CADDY_PASSWORD (default: changeme123)

## Volumes

Make sure to mount /workspace if you want your models, checkpoints, and LoRAs to persist.

-v /your/local/models:/workspace/models

