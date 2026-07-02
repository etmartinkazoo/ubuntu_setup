#!/usr/bin/env bash
# Install mise (runtime manager) and a baseline set of language runtimes.
source "${SETUP_LIB:?run via bootstrap.sh}/common.sh"

log "mise runtimes"

if ! have mise && [ ! -x "$HOME/.local/bin/mise" ]; then
  info "installing mise"
  curl -fsSL https://mise.run | sh
else
  ok "mise already installed"
fi

export PATH="$HOME/.local/bin:$PATH"
have mise || die "mise not on PATH after install"

# Baseline global runtimes. Projects override these with their own .mise.toml.
for tool in node@lts ruby@3 python@3; do
  info "mise use -g $tool"
  mise use -g "$tool" >/dev/null 2>&1 || warn "could not install $tool (skipping)"
done

ok "runtimes ready — node, ruby, python"
