# 🧱 Stage 1: Builder for Dependency Caching
FROM runpod/pytorch:2.1.0-py3.10-cuda11.8.0-devel-ubuntu22.04 AS builder

WORKDIR /workspace

# Install basic tools
RUN apt-get update -y && apt-get install -y \
    python3-venv curl unzip aria2 nano git \
    debian-keyring debian-archive-keyring apt-transport-https gnupg lsb-release

# Create a Python venv (only venv now, no cloning ComfyUI here)
RUN python3 -m venv comfyui-venv

# Optional placeholder folder for wheels
RUN mkdir -p /workspace/wheels

# --- End of builder stage ---

# 🏁 Final Runtime Stage
FROM runpod/pytorch:2.1.0-py3.10-cuda11.8.0-devel-ubuntu22.04

WORKDIR /workspace

# Install base tools + Caddy
RUN apt-get update -y && apt-get install -y \
    python3-venv curl unzip aria2 nano git \
    debian-keyring debian-archive-keyring apt-transport-https gnupg lsb-release \
    && curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy.gpg \
    && curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy.list \
    && apt-get update -y && apt-get install -y caddy

# Copy venv and wheels from builder stage
COPY --from=builder /workspace/comfyui-venv /workspace/comfyui-venv
COPY --from=builder /workspace/wheels /workspace/wheels

# Copy Start/Stop scripts
COPY start.sh /workspace/start.sh
COPY stop.sh /workspace/stop.sh

# Make scripts executable
RUN chmod +x /workspace/start.sh /workspace/stop.sh

# Setup environment variables
ENV CADDY_USERNAME=admin
ENV CADDY_PASSWORD=changeme123

# Open required ports
EXPOSE 80 443 8188

# Default command: Start server (ComfyUI + Caddy)
CMD ["/workspace/start.sh"]