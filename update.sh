#!/usr/bin/env bash
# Bring an existing install up to date with the latest version of the repo.
#
#   1. git pull (fast-forward only) and list the new commits
#   2. ./install.sh       link any new configs; existing links are left alone
#   3. packages.sh        install only packages and tools that are missing
#   4. Neovim             plugins to lazy-lock.json, treesitter parsers, Mason tools
#   5. tmux               install new plugins, remove ones no longer listed
#
# Usage: ./update.sh [--no-pull] [--skip-packages]

set -euo pipefail

# Everything runs inside main(), so bash has read the whole script before
# `git pull` can replace this file.
main() {
    local dotfiles pull=1 packages=1
    dotfiles="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    for arg in "$@"; do
        case "$arg" in
            --no-pull) pull=0 ;;
            --skip-packages) packages=0 ;;
            -h | --help)
                sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'
                return 0
                ;;
            *)
                echo "Unknown option: $arg" >&2
                return 1
                ;;
        esac
    done

    cd "$dotfiles"

    if [[ $pull -eq 1 ]]; then
        local before after
        before="$(git rev-parse HEAD)"
        info "Pulling the latest version"
        if ! git pull --ff-only; then
            warn "git pull failed. Commit or stash your local changes, then run ./update.sh again."
            return 1
        fi
        after="$(git rev-parse HEAD)"
        if [[ "$before" == "$after" ]]; then
            info "Already up to date"
        else
            info "New commits:"
            git --no-pager log --oneline "$before..$after"
            # Run the new version of this script for the remaining steps
            local args=(--no-pull)
            [[ $packages -eq 1 ]] || args+=(--skip-packages)
            exec "$dotfiles/update.sh" "${args[@]}"
        fi
    fi

    info "Linking configs"
    "$dotfiles/install.sh"

    if [[ $packages -eq 1 ]]; then
        info "Checking packages and tools"
        DOTFILES_UPDATING=1 "$dotfiles/scripts/packages.sh"
    fi

    if command -v nvim >/dev/null 2>&1; then
        info "Updating Neovim plugins to lazy-lock.json"
        nvim --headless "+Lazy! clean" "+Lazy! install" "+Lazy! restore" +qa
        info "Updating treesitter parsers and Mason tools (may take a few minutes)"
        nvim --headless \
            -c 'lua require("nvim-treesitter").update():wait(600000)' \
            -c 'lua require("config.treesitter").install_all(); require("config.treesitter").wait(600000)' \
            -c 'lua require("lazy").load({ plugins = { "mason-lspconfig.nvim" } }); require("config.tools").wait(600000)' \
            -c 'qall'
    fi

    local tpm="$dotfiles/.config/tmux/plugins/tpm"
    if [[ -x "$tpm/bin/install_plugins" && -f "$HOME/.config/tmux/tmux.conf" ]]; then
        info "Updating tmux plugins"
        "$tpm/bin/install_plugins" >/dev/null || warn "TPM could not install the tmux plugins"
        "$tpm/bin/clean_plugins" >/dev/null || warn "TPM could not remove old tmux plugins"
    fi

    info "Done. To pick up the changes:"
    cat <<'EOF'
  - Neovim: restart it
  - fish:   open a new shell
  - tmux:   press prefix r (or run: tmux source ~/.config/tmux/tmux.conf)
  - kitty:  press Ctrl+Shift+F5 or open a new window
EOF
}

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }

main "$@"
