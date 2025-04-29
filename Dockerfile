# Base image - RunPod Pytorch
FROM runpod/pytorch:2.1.0-py3.10-cuda11.8.0-devel-ubuntu22.04

# Working directory
WORKDIR /workspace

# Install necessary packages
RUN apt-get update -y && apt-get install -y \
    git python3-venv curl unzip aria2 nano \
    debian-keyring debian-archive-keyring apt-transport-https gnupg lsb-release \
    && curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg \
    && curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list \
    && apt-get update -y && apt-get install -y caddy \
    && rm -rf /var/lib/apt/lists/*

# Clone ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI.git

# Create venv and install requirements
RUN python3 -m venv comfyui-venv && \
    /bin/bash -c "source /workspace/comfyui-venv/bin/activate && \
    python -m ensurepip --upgrade && \
    pip install --upgrade pip && \
    pip install -r /workspace/ComfyUI/requirements.txt"

# Install ComfyUI Manager
RUN mkdir -p /workspace/ComfyUI/custom_nodes && \
    cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/Comfy-Org/ComfyUI-Manager.git

# Copy startup scripts
COPY start.sh /workspace/start.sh
COPY stop.sh /workspace/stop.sh

RUN chmod +x /workspace/start.sh /workspace/stop.sh

# Expose needed ports
EXPOSE 80 443 8188

# Environment variables for Caddy BasicAuth
ENV CADDY_USERNAME=admin
ENV CADDY_PASSWORD=changeme123

# Start the server
CMD ["/workspace/start.sh"]