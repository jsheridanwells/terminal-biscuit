#!/usr/bin/env bash
#
# link.sh — symlink nvim + tmux configs from ~/.config to this repo
# existing copies are backed up
set -euo pipefail

# --- locate the repo (the directory this script lives in) ---------------------
# Lets you run the script from anywhere, not just the repo root.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- target locations (honor XDG, fall back to ~/.config) ---------------------
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
NVIM_DIR="$CONFIG/nvim"
TMUX_CONF="$CONFIG/tmux.conf"

STAMP="$(date +%Y%m%d-%H%M%S)"

# Back up an existing file before we replace it.
backup() {
  local target="$1"
  if [ -e "$target" ] || [ -L "$target" ]; then
    mv "$target" "${target}.bak.${STAMP}"
    echo "    backed up → $(basename "$target").bak.${STAMP}"
  fi
}

# Create a symlink from dest → src. Skip if already linked correctly,
# back up the old version otherwise.
link_config() {
  local src="$1" dest="$2"
  local target_name="$(basename "$dest")"

  if [ ! -e "$src" ]; then
    echo "    skip: $(basename "$src") not found in repo"
    return
  fi

  # Check if symlink already points to the right place
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    echo "    linked: $target_name → $(basename "$src")"
    return
  fi

  backup "$dest"
  ln -s "$src" "$dest"
  echo "    linked: $target_name → $(basename "$src")"
}

echo "Linking configs from: $SCRIPT_DIR"
echo

# --- nvim ---------------------------------------------------------------------
echo "nvim  →  $NVIM_DIR"
link_config "$SCRIPT_DIR/nvim" "$NVIM_DIR"
echo

# --- tmux ---------------------------------------------------------------------
echo "tmux  →  $TMUX_CONF"
link_config "$SCRIPT_DIR/tmux/tmux.conf" "$TMUX_CONF"
echo

echo "Done."
echo
echo "Next steps"
echo "──────────"
echo "  Reload tmux:  tmux source-file \"$TMUX_CONF\""
echo "  (or press  prefix + r)"
