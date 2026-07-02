#!/usr/bin/env bash
# Install the curated apt package set from setup/packages.txt.
source "${SETUP_LIB:?run via bootstrap.sh}/common.sh"

log "apt packages"

mapfile -t pkgs < <(grep -vE '^\s*(#|$)' "$SETUP_DIR/packages.txt")
info "${#pkgs[@]} packages from packages.txt"

export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -qq

# Install only what's missing so re-runs are fast.
missing=()
for p in "${pkgs[@]}"; do
  dpkg -s "$p" >/dev/null 2>&1 || missing+=("$p")
done

if [ "${#missing[@]}" -eq 0 ]; then
  ok "all packages already installed"
else
  info "installing: ${missing[*]}"
  sudo apt-get install -y -qq "${missing[@]}"
  ok "installed ${#missing[@]} packages"
fi

# fd ships as fdfind on Debian/Ubuntu — expose the familiar name.
if have fdfind && ! have fd; then
  mkdir -p "$HOME/.local/bin"
  ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  info "linked fd → fdfind"
fi
