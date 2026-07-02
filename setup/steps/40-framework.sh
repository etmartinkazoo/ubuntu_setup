#!/usr/bin/env bash
# Framework-specific tweaks. Guarded behind a hardware check — on any other
# machine this step reports that it skipped and does nothing.
source "${SETUP_LIB:?run via bootstrap.sh}/common.sh"

log "framework fixes"

if ! is_framework; then
  info "not a Framework device ($(framework_model)) — skipping"
  exit 0
fi

ok "detected Framework: $(framework_model)"

# Fingerprint reader (Goodix) — present on 13 and 16.
if ! dpkg -s fprintd >/dev/null 2>&1; then
  info "installing fprintd for the fingerprint reader"
  sudo apt-get install -y -qq fprintd libpam-fprintd
else
  info "fprintd already installed"
fi

# Better suspend behaviour: prefer deep sleep where the firmware allows it.
if [ -w /sys/power/mem_sleep ] 2>/dev/null || sudo test -e /sys/power/mem_sleep; then
  info "suspend: mem_sleep available (configure in firmware for deepest sleep)"
fi

# Fractional scaling for HiDPI panels (no-op if not on GNOME/Wayland).
if have gsettings; then
  gsettings set org.gnome.mutter experimental-features \
    "['scale-monitor-framebuffer']" 2>/dev/null \
    && info "enabled fractional scaling" \
    || info "skipped fractional scaling (no GNOME session)"
fi

ok "framework tweaks applied"
