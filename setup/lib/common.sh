#!/usr/bin/env bash
# Shared helpers for the bootstrap and its steps.
# Sourced by setup/bootstrap.sh; also usable when running a step directly.

set -euo pipefail

# ── paths ─────────────────────────────────────────────────────────
SETUP_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_DIR="$(cd "$SETUP_LIB/.." && pwd)"
REPO_DIR="$(cd "$SETUP_DIR/.." && pwd)"
DOTFILES_DIR="$REPO_DIR/dotfiles"
BACKUP_ROOT="$HOME/.dotfiles-backup"

# Set once per run so every backed-up file lands in the same folder.
: "${BOOTSTRAP_STAMP:=$(date +%Y-%m-%dT%H-%M-%S)}"
export BOOTSTRAP_STAMP SETUP_LIB SETUP_DIR REPO_DIR DOTFILES_DIR

# ── output ────────────────────────────────────────────────────────
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  C_ORANGE=$'\033[38;5;208m'; C_DIM=$'\033[2m'; C_BOLD=$'\033[1m'; C_RESET=$'\033[0m'
else
  C_ORANGE=""; C_DIM=""; C_BOLD=""; C_RESET=""
fi

log()  { printf '%s→%s %s\n' "$C_ORANGE" "$C_RESET" "$*"; }
info() { printf '  %s%s%s\n' "$C_DIM" "$*" "$C_RESET"; }
ok()   { printf '%s✓%s %s\n' "$C_ORANGE" "$C_RESET" "$*"; }
warn() { printf '%s!%s %s\n' "$C_ORANGE" "$C_RESET" "$*" >&2; }
die()  { printf '%s✗%s %s\n' "$C_ORANGE" "$C_RESET" "$*" >&2; exit 1; }

# ── predicates ────────────────────────────────────────────────────
have() { command -v "$1" >/dev/null 2>&1; }

confirm() {
  # confirm "question" — auto-yes when ASSUME_YES is set.
  [ "${ASSUME_YES:-0}" = "1" ] && return 0
  local reply
  read -r -p "  $1 [y/N] " reply
  [[ "$reply" =~ ^[Yy]$ ]]
}

is_framework() {
  local vendor="/sys/class/dmi/id/sys_vendor"
  [ -r "$vendor" ] && grep -qi 'framework' "$vendor"
}

framework_model() {
  cat /sys/class/dmi/id/product_name 2>/dev/null || echo "unknown"
}

# ── the core primitive: symlink a dotfile, backing up any original ──
link_file() {
  # link_file <source-in-repo> <target-in-home>
  local src="$1" dest="$2"

  [ -e "$src" ] || die "missing source: $src"

  # Already linked to us? Nothing to do.
  if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$(readlink -f "$src")" ]; then
    info "linked  ${dest/#$HOME/~}"
    return 0
  fi

  # Real file or a foreign symlink in the way — back it up first.
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    local backup="$BACKUP_ROOT/$BOOTSTRAP_STAMP"
    mkdir -p "$backup"
    mv "$dest" "$backup/$(basename "$dest")"
    info "backed up ${dest/#$HOME/~} → ${backup/#$HOME/~}/"
  fi

  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  ok "linked  ${dest/#$HOME/~} → ${src/#$HOME/~}"
}
