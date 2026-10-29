#!/usr/bin/env bash
# Remove the symlinks created by install.sh.
#
# Only links that point into this repository are removed. Backups made by
# install.sh (*.bak-<timestamp>) are left in place for you to restore.
#
# Usage: ./uninstall.sh [--dry-run]

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=0
if [[ "${1:-}" == "--dry-run" ]]; then DRY_RUN=1; fi

candidates=(
    "$HOME/.bashrc"
    "$HOME/.config/fish"
    "$HOME/.config/kitty"
    "$HOME/.config/nvim"
    "$HOME/.config/tmux"
    "$HOME/.config/git/config"
)
for script in "$DOTFILES"/scripts/bin/*; do
    if [[ -f "$script" ]]; then
        candidates+=("$HOME/.local/bin/$(basename "$script")")
    fi
done

for path in "${candidates[@]}"; do
    if [[ -L "$path" && "$(readlink "$path")" == "$DOTFILES"/* ]]; then
        echo "remove  ${path/#$HOME/\~}"
        if [[ $DRY_RUN -eq 0 ]]; then
            rm "$path"
        fi
        latest="$(compgen -G "$path.bak-*" | sort | tail -n 1 || true)"
        if [[ -n "$latest" ]]; then
            echo "        backup available: ${latest/#$HOME/\~}"
        fi
    fi
done
