#!/usr/bin/env bash
#
# ubuntu_setup — one-command workstation bootstrap
# https://github.com/etmartinkazoo/ubuntu_setup
#
# Usage:
#   ./setup/bootstrap.sh              run every step (idempotent)
#   ./setup/bootstrap.sh --only NAME  run one step (apt|herdr|mise|dotfiles|
#                                      privacy|dns|hardening|power|firefox)
#   ./setup/bootstrap.sh --verify     check the environment, change nothing
#   ./setup/bootstrap.sh --restore    relink your most recent backed-up dotfiles
#   ./setup/bootstrap.sh --help
#
# Environment:
#   ASSUME_YES=1   accept defaults, no prompts (for unattended installs)
#   NO_COLOR=1     disable coloured output

set -euo pipefail

SETUP_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")/lib" && pwd)"
source "$SETUP_LIB/common.sh"

usage() { sed -n '3,16p' "$0" | sed 's/^#\s\?//'; }

# ── step registry ─────────────────────────────────────────────────
declare -A STEP=(
  [apt]="10-apt.sh"
  [herdr]="25-herdr.sh"
  [mise]="20-mise.sh"
  [dotfiles]="30-dotfiles.sh"
  [privacy]="40-privacy.sh"
  [dns]="45-dns.sh"
  [hardening]="50-hardening.sh"
  [power]="60-power.sh"
  [firefox]="70-firefox.sh"
)
ORDER=(apt herdr mise dotfiles privacy dns hardening power firefox)

run_step() {
  local name="$1"
  local file="${STEP[$name]:-}"
  [ -n "$file" ] || die "unknown step: $name"
  bash "$SETUP_DIR/steps/$file"
  echo
}

preflight() {
  log "preflight"
  [ -r /etc/os-release ] && . /etc/os-release || true
  case "${ID:-}" in
    ubuntu|debian|pop|linuxmint) info "os: ${PRETTY_NAME:-$ID}" ;;
    *) warn "this targets Ubuntu; ${PRETTY_NAME:-unknown OS} may need adjustments" ;;
  esac
  have sudo || die "sudo is required"
  info "keeping sudo warm"
  sudo -v || die "could not obtain sudo"
  ok "preflight passed"
  echo
}

do_verify() {
  local fail=0
  log "verify"
  for t in git herdr curl mise ufw; do
    if have "$t"; then ok "$t"; else warn "$t missing"; fail=1; fi
  done
  for f in .bashrc .gitconfig .config/herdr/config.toml; do
    if [ -L "$HOME/$f" ]; then ok "~/$f linked"; else warn "~/$f not linked"; fail=1; fi
  done
  if have ufw && sudo ufw status 2>/dev/null | grep -q "Status: active"; then
    ok "firewall active"
  else
    warn "firewall not active"; fail=1
  fi
  if [ -f /etc/firefox/policies/policies.json ]; then ok "firefox policy installed"; else warn "firefox policy missing"; fail=1; fi
  if resolvectl status 2>/dev/null | grep -qi 'DNSOverTLS.*yes\|+DNSOverTLS'; then ok "encrypted DNS active"; else info "encrypted DNS not detected"; fi
  if is_framework; then info "hardware: $(framework_model)"; fi
  echo
  [ "$fail" -eq 0 ] && ok "environment matches the repo" || die "environment is incomplete — run ./setup/bootstrap.sh"
}

do_restore() {
  log "restore"
  [ -d "$BACKUP_ROOT" ] || die "no backups found at $BACKUP_ROOT"
  local latest
  latest="$(ls -1 "$BACKUP_ROOT" | sort | tail -1)"
  [ -n "$latest" ] || die "no backups found"
  info "restoring from $latest"
  for f in "$BACKUP_ROOT/$latest"/.*; do
    local base; base="$(basename "$f")"
    [ "$base" = "." ] || [ "$base" = ".." ] && continue
    [ -f "$f" ] || continue
    [ -L "$HOME/$base" ] && rm -f "$HOME/$base"
    cp -a "$f" "$HOME/$base"
    ok "restored ~/$base"
  done
}

banner() {
  printf '\n%s  ubuntu_setup%s  %s— a power-user Ubuntu baseline%s\n\n' \
    "$C_BOLD" "$C_RESET" "$C_DIM" "$C_RESET"
}

# ── argument handling ─────────────────────────────────────────────
main() {
  case "${1:-}" in
    -h|--help) usage; exit 0 ;;
    --verify)  banner; do_verify; exit 0 ;;
    --restore) banner; do_restore; exit 0 ;;
    --only)
      [ -n "${2:-}" ] || die "--only needs a step name (${ORDER[*]})"
      banner; preflight; run_step "$2"; ok "step '$2' complete"; exit 0 ;;
    "" ) ;; # fall through to full run
    * ) die "unknown option: $1 (try --help)" ;;
  esac

  banner
  preflight
  local start=$SECONDS
  for step in "${ORDER[@]}"; do run_step "$step"; done
  local mins=$(( (SECONDS - start) / 60 )) secs=$(( (SECONDS - start) % 60 ))
  ok "done in ${mins}m ${secs}s"
  info "restart your shell:  exec bash"
}

main "$@"
