#!/bin/bash

set -e

echo ""
echo "========================================"
echo "🚀 Starting Caddy + ComfyUI Server"
echo "========================================"
echo ""

# ✅ Clone ComfyUI if not already present
if [ ! -d "/workspace/ComfyUI" ]; then
    echo "📥 Cloning ComfyUI..."
    git clone https://github.com/comfyanonymous/ComfyUI.git
else
    echo "✅ ComfyUI already exists. Skipping clone."
fi

# ✅ Clone ComfyUI Manager if not already present
if [ ! -d "/workspace/ComfyUI/custom_nodes/ComfyUI-Manager" ]; then
    echo "📥 Cloning ComfyUI-Manager..."
    mkdir -p /workspace/ComfyUI/custom_nodes
    git clone https://github.com/Comfy-Org/ComfyUI-Manager.git /workspace/ComfyUI/custom_nodes/ComfyUI-Manager
else
    echo "✅ ComfyUI Manager already exists. Skipping clone."
fi

# 🔒 Activate venv
source /workspace/comfyui-venv/bin/activate

# 📦 Ensure dependencies are installed (from pre-built wheels if possible)
pip install --upgrade pip
pip install -r /workspace/ComfyUI/requirements.txt || echo "⚠️ Warning: Some requirements may already be installed."

# ⏳ Wait briefly (optional)
echo "⏳ Waiting a few seconds to stabilize before launch..."
sleep 3

# ✅ Start ComfyUI (detached)
echo "🚀 Launching ComfyUI..."
nohup python /workspace/ComfyUI/main.py --listen --port 8188 > /workspace/comfyui.log 2>&1 &

# ✅ Generate Caddyfile if not already exists
if [ ! -f "/etc/caddy/Caddyfile" ]; then
    echo "🔐 Creating Caddyfile..."
    HASHED_PASS=$(caddy hash-password --plaintext "$CADDY_PASSWORD")

    cat <<EOF > /etc/caddy/Caddyfile
:80 {
    route {
        basicauth /* {
            $CADDY_USERNAME $HASHED_PASS
        }
        reverse_proxy localhost:8188
    }
}
EOF
else
    echo "✅ Caddyfile already exists. Skipping creation."
fi

# ✅ Start Caddy
echo "🌐 Starting Caddy..."
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile > /workspace/caddy.log 2>&1 &
echo ""
echo "========================================"
echo "🎯 Ready at: http://<your-runpod-subdomain>"
echo "🔐 Login with: $CADDY_USERNAME / (The Password you set in the Environment Variables)"
echo "📜 Logs: tail -f /workspace/comfyui.log"
echo "========================================"