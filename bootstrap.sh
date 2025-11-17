#!/usr/bin/env bash

set -e

# 1. Define where to put the venv
BPY_VENV="$HOME/.basedpyright-venv"

echo "[*] Creating Python virtual environment at $BPY_VENV …"
python3 -m venv "$BPY_VENV"

echo "[*] Activating venv and upgrading pip…"
# shellcheck disable=SC1090
source "$BPY_VENV/bin/activate"

pip install --upgrade pip setuptools wheel

echo "[*] Installing BasedPyright in venv…"
pip install basedpyright  # BasedPyright from PyPI. :contentReference[oaicite:0]{index=0}

# 2. Write a small launcher script to use this langserver
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"

LAUNCHER="$BIN_DIR/basedpyright-ls"
cat > "$LAUNCHER" <<EOF
#!/usr/bin/env bash
# This script activates the venv and then runs basedpyright-langserver
source "$BPY_VENV/bin/activate"
exec basedpyright-langserver --stdio
EOF

chmod +x "$LAUNCHER"
echo "[*] Created launcher script $LAUNCHER"

# 3. Add ~/.local/bin to your PATH in your shell profile
SHELL_PROFILE="$HOME/.profile"
if ! grep -q 'basedpyright-venv' "$SHELL_PROFILE"; then
  echo "export PATH=\"$BIN_DIR:\$PATH\"" >> "$SHELL_PROFILE"
  echo "source \"$BPY_VENV/bin/activate\"" >> "$SHELL_PROFILE"
  echo "[*] Updated PATH and auto-activation in $SHELL_PROFILE"
else
  echo "[*] PATH seems already configured in $SHELL_PROFILE"
fi

echo "[*] Bootstrap complete. Please restart your shell or run 'source $SHELL_PROFILE'."
echo "Then configure Neovim LSP to use command: $LAUNCHER"

