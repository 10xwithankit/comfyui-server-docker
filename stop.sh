#!/bin/bash

# 🛑 Exit if any command fails
set -e

echo "========================================"
echo "🛑 Stopping ComfyUI + Caddy Server"
echo "========================================"

# Kill ComfyUI backend
pkill -f "python /workspace/ComfyUI/main.py" || echo "ComfyUI already stopped."

# Kill Caddy
pkill -f "caddy run" || echo "Caddy already stopped."

echo "✅ Both ComfyUI and Caddy have been stopped."