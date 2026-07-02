#!/usr/bin/env bash
# Symlink the dotfiles into $HOME, backing up any originals first.
source "${SETUP_LIB:?run via bootstrap.sh}/common.sh"

log "dotfiles"

# repo path  →  home target
link_file "$DOTFILES_DIR/bashrc"         "$HOME/.bashrc"
link_file "$DOTFILES_DIR/profile"        "$HOME/.profile"
link_file "$DOTFILES_DIR/tmux.conf"      "$HOME/.tmux.conf"
link_file "$DOTFILES_DIR/bash/aliases.sh" "$HOME/.config/ubuntu_setup/aliases.sh"

# git identity is personal — write a local config that the tracked gitconfig
# includes, rather than symlinking name/email into the repo.
link_file "$DOTFILES_DIR/gitconfig" "$HOME/.gitconfig"
if [ ! -f "$HOME/.gitconfig.local" ]; then
  info "creating ~/.gitconfig.local for your name and email"
  cat > "$HOME/.gitconfig.local" <<'EOF'
[user]
    name = Your Name
    email = you@example.com
EOF
  warn "edit ~/.gitconfig.local with your name and email"
fi

ok "dotfiles linked"
