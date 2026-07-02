#!/usr/bin/env bash
# Security hardening: a sensible baseline that won't get in your way.
source "${SETUP_LIB:?run via bootstrap.sh}/common.sh"

log "hardening"

# ── firewall: deny inbound, allow outbound ────────────────────────
if have ufw; then
  sudo ufw --force default deny incoming >/dev/null
  sudo ufw --force default allow outgoing >/dev/null
  sudo ufw --force enable >/dev/null
  ok "ufw active — inbound denied by default"
else
  warn "ufw not installed (check packages.txt)"
fi

# ── automatic security updates ────────────────────────────────────
if [ -d /etc/apt/apt.conf.d ]; then
  sudo tee /etc/apt/apt.conf.d/20auto-upgrades >/dev/null <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF
  info "unattended security upgrades enabled"
fi

# ── kernel/network sysctl hardening ───────────────────────────────
sudo tee /etc/sysctl.d/90-ubuntu-setup-hardening.conf >/dev/null <<'EOF'
# Restrict kernel pointer and dmesg exposure
kernel.kptr_restrict = 2
kernel.dmesg_restrict = 1
# Network: SYN cookies, ignore ICMP broadcasts, reverse-path filter
net.ipv4.tcp_syncookies = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.conf.all.rp_filter = 1
# Disable core dumps from setuid programs
fs.suid_dumpable = 0
EOF
sudo sysctl --system >/dev/null 2>&1 || true
info "applied sysctl hardening"

ok "baseline hardening applied"
