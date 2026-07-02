#!/usr/bin/env bash
# Efficiency & battery life. Framework-specific fixes are applied when a
# Framework mainboard is detected; on any other device those steps skip and
# the generic power tuning still runs.
source "${SETUP_LIB:?run via bootstrap.sh}/common.sh"

log "power & efficiency"

# ── generic: auto-tune power on every boot ────────────────────────
# powertop --auto-tune enables the kernel's power-saving knobs. Wrap it in a
# oneshot service so it runs at each boot, not just once.
if have powertop; then
  sudo tee /etc/systemd/system/powertop-autotune.service >/dev/null <<'EOF'
[Unit]
Description=powertop auto-tune (ubuntu_setup)
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/sbin/powertop --auto-tune

[Install]
WantedBy=multi-user.target
EOF
  sudo systemctl enable --now powertop-autotune.service >/dev/null 2>&1 || true
  ok "powertop auto-tune enabled at boot"
else
  warn "powertop not installed (check packages.txt)"
fi

# ── Framework-specific ────────────────────────────────────────────
if ! is_framework; then
  info "not a Framework device ($(framework_model)) — generic tuning only"
  ok "power tuning applied"
  exit 0
fi

ok "detected Framework: $(framework_model)"

# Fingerprint reader (Goodix) — present on Framework 13 and 16.
if ! dpkg -s fprintd >/dev/null 2>&1; then
  info "installing fprintd for the fingerprint reader"
  sudo apt-get install -y -qq fprintd libpam-fprintd
else
  info "fprintd already installed"
fi

# Prefer the deepest suspend state the firmware allows (better idle battery).
if [ -e /sys/power/mem_sleep ]; then
  info "suspend: mem_sleep present — set 'deep' in firmware for lowest idle drain"
fi

ok "framework power tweaks applied"
