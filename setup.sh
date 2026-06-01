#!/usr/bin/env bash
#
# init.sh — install nvim + tmux configs into ~/.config
# existing copies are backed up
set -euo pipefail

# --- locate the repo (the directory this script lives in) ---------------------
# Lets you run the script from anywhere, not just the repo root.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- target locations (honor XDG, fall back to ~/.config) ---------------------
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
NVIM_DIR="$CONFIG/nvim"
TMUX_DIR="$CONFIG/tmux"

STAMP="$(date +%Y%m%d-%H%M%S)"

# Back up an existing file before we replace it.
backup() {
  local target="$1"
  if [ -e "$target" ] || [ -L "$target" ]; then
    mv "$target" "${target}.bak.${STAMP}"
    echo "    backed up → $(basename "$target").bak.${STAMP}"
  fi
}

# Copy src → dest. Skip if identical (keeps the config dir tidy on re-runs),
# back up the old version otherwise.
install_file() {
  local src="$1" dest="$2"
  if [ ! -f "$src" ]; then
    echo "    skip: $(basename "$src") not found in repo"
    return
  fi
  if [ -f "$dest" ] && cmp -s "$src" "$dest"; then
    echo "    unchanged: $(basename "$dest")"
    return
  fi
  backup "$dest"
  cp "$src" "$dest"
  echo "    installed: $(basename "$dest")"
}

echo "Installing configs from: $SCRIPT_DIR"
echo

# --- nvim ---------------------------------------------------------------------
echo "nvim  →  $NVIM_DIR"
mkdir -p "$NVIM_DIR/lua"
install_file "$SCRIPT_DIR/nvim/init.lua"             "$NVIM_DIR/init.lua"
install_file "$SCRIPT_DIR/nvim/lua/window_close.lua" "$NVIM_DIR/lua/window_close.lua"
install_file "$SCRIPT_DIR/nvim/lazy-lock.json"       "$NVIM_DIR/lazy-lock.json"
echo

# --- tmux ---------------------------------------------------------------------
echo "tmux  →  $TMUX_DIR"
mkdir -p "$TMUX_DIR"
install_file "$SCRIPT_DIR/tmux/tmux.conf" "$TMUX_DIR/tmux.conf"
echo

echo "Done."
echo
echo "Next steps"
echo "──────────"
echo "  1. Launch  nvim.  lazy.nvim bootstraps and installs every plugin,"
echo "     Mason pulls the LSP servers, and Treesitter compiles its parsers."
echo "     Let it settle, then quit and relaunch once."
echo
echo "  2. One-time C# server (large download):  in nvim run"
echo "       :MasonInstall roslyn"
echo
echo "  3. Reload tmux:  tmux source-file \"$TMUX_DIR/tmux.conf\""
echo "     (or press  prefix + r).  If Ctrl+Shift+<key> passthrough seems off,"
echo "     fully restart the server when convenient:  tmux kill-server"
