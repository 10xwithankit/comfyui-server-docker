#!/bin/bash

# 🛑 Exit if any command fails
set -e

echo "========================================"
echo "🚀 Starting ComfyUI + Caddy Server"
echo "========================================"

# Activate venv
source /workspace/comfyui-venv/bin/activate

# Start ComfyUI backend
echo "🚀 Starting ComfyUI backend..."
nohup python /workspace/ComfyUI/main.py --listen --port 8188 > /workspace/comfyui.log 2>&1 &

# Wait for ComfyUI to be available
echo "⏳ Waiting for ComfyUI server to be ready..."
for i in {1..30}; do
    if nc -z localhost 8188; then
        echo "✅ ComfyUI is ready!"
        break
    else
        echo "⏳ Waiting... ($i/30)"
        sleep 1
    fi
done

# Create Caddyfile dynamically
echo "🚀 Creating Caddyfile..."
cat <<EOF > /etc/caddy/Caddyfile
:80 {
    route {
        basicauth /* {
            ${CADDY_USERNAME} $(caddy hash-password --plaintext "${CADDY_PASSWORD}")
        }
        reverse_proxy localhost:8188
    }
}
EOF

# Start Caddy
echo "🚀 Starting Caddy reverse proxy..."
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile > /workspace/caddy.log 2>&1 &

echo ""
echo "========================================"
echo "🎯 Final Instructions:"
echo ""
echo "🖥️ Access your server: http://<your-runpod-url>"
echo "🔐 BasicAuth Username: $CADDY_USERNAME"
echo "🔐 BasicAuth Password: (the password you set)"
echo "📜 Check ComfyUI logs: tail -f /workspace/comfyui.log"
echo "📜 Check Caddy logs: tail -f /workspace/caddy.log"
echo "========================================"