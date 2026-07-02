# Aliases & functions — sourced by ~/.bashrc.
# Add your own here; commit them to your fork so they follow you everywhere.

# ── ls shorthands ─────────────────────────────────────────────────
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# ── safety rails — prompt before destroying things ────────────────
alias rm='rm -I'
alias cp='cp -i'
alias mv='mv -i'

# ── git ───────────────────────────────────────────────────────────
alias gs='git status -sb'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate -20'

# gp "message" branch — stage, commit, and push in one move.
gp() {
  git add . &&
  git commit -m "$1" &&
  git push origin "${2:-$(git rev-parse --abbrev-ref HEAD)}"
}

# mkcd dir — make a directory and change into it.
mkcd() { mkdir -p "$1" && cd "$1"; }

# ── your aliases below ────────────────────────────────────────────
