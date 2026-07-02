#!/usr/bin/env bash
# Encrypted DNS: route every lookup on the machine through systemd-resolved
# over TLS to Quad9, which also blackholes known-malicious domains.
# Swap the resolver by editing the DNS= lines below.
source "${SETUP_LIB:?run via bootstrap.sh}/common.sh"

log "encrypted DNS"

if ! have resolvectl && ! systemctl list-unit-files 2>/dev/null | grep -q systemd-resolved; then
  warn "systemd-resolved not present — skipping encrypted DNS"
  exit 0
fi

sudo mkdir -p /etc/systemd/resolved.conf.d
sudo tee /etc/systemd/resolved.conf.d/10-candor-dns.conf >/dev/null <<'EOF'
# Managed by Ubuntu Candor — encrypted DNS over TLS to Quad9.
[Resolve]
DNS=9.9.9.9#dns.quad9.net 2620:fe::fe#dns.quad9.net
FallbackDNS=149.112.112.112#dns.quad9.net 2620:fe::9#dns.quad9.net
DNSOverTLS=yes
EOF

sudo systemctl restart systemd-resolved 2>/dev/null || true
ok "DNS over TLS → Quad9 (edit /etc/systemd/resolved.conf.d/10-candor-dns.conf to change)"
