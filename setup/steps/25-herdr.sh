#!/usr/bin/env bash
# Install herdr — the keyboard-driven, agent-aware terminal multiplexer.
# Single Rust binary, no account, no telemetry. https://herdr.dev
source "${SETUP_LIB:?run via bootstrap.sh}/common.sh"

log "herdr"

if have herdr || [ -x "$HOME/.local/bin/herdr" ]; then
  ok "herdr already installed"
else
  info "installing herdr from herdr.dev/install.sh"
  curl -fsSL https://herdr.dev/install.sh | sh
fi

export PATH="$HOME/.local/bin:$PATH"
have herdr && ok "herdr $(herdr --version 2>/dev/null | head -1)" \
           || warn "herdr not on PATH yet — restart your shell"
