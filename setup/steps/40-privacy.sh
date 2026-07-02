#!/usr/bin/env bash
# Privacy: turn off the bits of a stock Ubuntu install that phone home.
# Everything here is reversible — see docs/uninstalling.
source "${SETUP_LIB:?run via bootstrap.sh}/common.sh"

log "privacy — silencing calls home"

# Canonical's opt-in metrics and the Debian popularity contest.
for pkg in ubuntu-report popularity-contest apport whoopsie; do
  if dpkg -s "$pkg" >/dev/null 2>&1; then
    info "removing $pkg"
    sudo apt-get purge -y -qq "$pkg" >/dev/null
  else
    info "$pkg not present"
  fi
done

# The "news" line in the message-of-the-day fetches remote content on login.
if [ -f /etc/default/motd-news ]; then
  sudo sed -i 's/^ENABLED=.*/ENABLED=0/' /etc/default/motd-news
  info "disabled motd-news"
fi

# NetworkManager's connectivity check pings a Canonical endpoint on every
# network change. Turn it off.
if [ -d /etc/NetworkManager ]; then
  echo -e '[connectivity]\nenabled=false' \
    | sudo tee /etc/NetworkManager/conf.d/20-no-connectivity-check.conf >/dev/null
  info "disabled NetworkManager connectivity check"
fi

# Opt out of Ubuntu's optional hardware/usage report if the tool lingers.
have ubuntu-report && ubuntu-report -f send no >/dev/null 2>&1 || true

ok "phone-home disabled"
