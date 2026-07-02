#!/usr/bin/env bash
# Firefox for focus: a hardened, quiet default profile, uBlock Origin
# force-installed, and the distraction blocklist compiled into its filters.
# Applies via Firefox enterprise policy — takes effect on the next launch.
source "${SETUP_LIB:?run via bootstrap.sh}/common.sh"

log "firefox — defaults, uBlock, blocklist"

TEMPLATE="$SETUP_DIR/firefox/policies.json"
BLOCKLIST="$SETUP_DIR/blocklist.txt"
POLICY_DIR="/etc/firefox/policies"

have jq || die "jq is required for the firefox step (it's in packages.txt)"

# Turn each blocklist domain into a uBlock static filter: `||domain^`.
filters="$(grep -vE '^\s*(#|$)' "$BLOCKLIST" | sed 's#^#||#; s#$#^#')"
count="$(printf '%s\n' "$filters" | grep -c . || true)"
info "compiling $count domains into uBlock filters"

# Inject the filters into uBlock's managed settings inside the policy.
sudo mkdir -p "$POLICY_DIR"
jq --arg f "$filters" \
  '.policies["3rdparty"].Extensions["uBlock0@raymondhill.net"].adminSettings.userFilters = $f' \
  "$TEMPLATE" | sudo tee "$POLICY_DIR/policies.json" >/dev/null

ok "policy installed → $POLICY_DIR/policies.json"
info "uBlock Origin force-installed; blocklist active on next Firefox launch"
info "edit setup/blocklist.txt and re-run: ./setup/bootstrap.sh --only firefox"
