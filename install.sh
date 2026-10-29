#!/usr/bin/env bash
# Link the configs in this repository into $HOME.
#
# Safe to run more than once: links that already point here are left alone,
# and anything else in the way is renamed to <name>.bak-<timestamp> first.
#
# Usage: ./install.sh [--dry-run]

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
DRY_RUN=0

for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=1 ;;
        -h | --help)
            sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *)
            echo "Unknown option: $arg" >&2
            exit 1
            ;;
    esac
done

# shellcheck source=scripts/links.sh
source "$DOTFILES/scripts/links.sh"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }

run() {
    if [[ $DRY_RUN -eq 1 ]]; then
        echo "    [dry-run] $*"
    else
        "$@"
    fi
}

link() {
    local src="$1" dest="$2"

    if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
        echo "    ok      ${dest/#$HOME/\~}"
        return
    fi

    if [[ -e "$dest" || -L "$dest" ]]; then
        echo "    backup  ${dest/#$HOME/\~} -> ${dest/#$HOME/\~}.bak-$STAMP"
        run mv "$dest" "$dest.bak-$STAMP"
    fi

    echo "    link    ${dest/#$HOME/\~} -> $src"
    run mkdir -p "$(dirname "$dest")"
    run ln -s "$src" "$dest"
}

info "Linking configs from $DOTFILES"
for entry in "${LINKS[@]}"; do
    link "$DOTFILES/${entry%%:*}" "$HOME/${entry#*:}"
done

# Git identity lives outside the repo so it never gets committed or shared.
GIT_LOCAL="$HOME/.config/git/config.local"
if [[ -f "$GIT_LOCAL" ]]; then
    info "Git identity: using existing ${GIT_LOCAL/#$HOME/\~}"
else
    name="${DOTFILES_GIT_NAME:-}"
    email="${DOTFILES_GIT_EMAIL:-}"
    if [[ ( -z "$name" || -z "$email" ) && -t 0 ]]; then
        info "Git identity (stored in ${GIT_LOCAL/#$HOME/\~}, not in the repo)"
        [[ -n "$name" ]] || read -rp "    Name:  " name
        [[ -n "$email" ]] || read -rp "    Email: " email
    fi
    if [[ -n "$name" && -n "$email" ]]; then
        if [[ $DRY_RUN -eq 1 ]]; then
            echo "    [dry-run] write $GIT_LOCAL"
        else
            mkdir -p "$(dirname "$GIT_LOCAL")"
            # git config escapes quotes and backslashes in the values for us
            git config --file "$GIT_LOCAL" user.name "$name"
            git config --file "$GIT_LOCAL" user.email "$email"
        fi
    else
        warn "No git identity set. Create $GIT_LOCAL or rerun ./install.sh."
    fi
fi

# ~/.gitconfig is read after ~/.config/git/config and wins on conflicts.
if [[ -f "$HOME/.gitconfig" ]]; then
    warn "A ~/.gitconfig file exists and overrides ~/.config/git/config." \
        "Move what you want to keep into ~/.config/git/config.local, then delete ~/.gitconfig."
fi

info "Done. Open a new terminal to pick up the shell config."
