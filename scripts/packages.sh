#!/usr/bin/env bash
# Install the packages and tools these dotfiles expect on Fedora Asahi Remix.
#
# Uses only the official Fedora repositories (no COPR). Run it as your normal
# user; it calls sudo for dnf when needed.
#
# Usage: ./scripts/packages.sh [--cli-only]
#
#   --cli-only   Skip desktop packages (kitty, Fcitx5, snapper, Nerd Font).
#                Useful inside a toolbox or a container.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLI_ONLY=0
for arg in "$@"; do
    case "$arg" in
        --cli-only) CLI_ONLY=1 ;;
        -h | --help)
            sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *)
            echo "Unknown option: $arg" >&2
            exit 1
            ;;
    esac
done

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }

if [[ $EUID -eq 0 ]]; then
    SUDO=()
else
    SUDO=(sudo)
fi

# --- dnf packages ---------------------------------------------------------

CLI_PACKAGES=(
    # Shell and terminal tools
    fish tmux git git-lfs gh btop bat ripgrep fd-find
    curl unzip tar xz fontconfig
    # System clipboard for Neovim on Wayland
    wl-clipboard
    # Neovim and what its plugins need (treesitter parsers, Mason servers)
    neovim tree-sitter-cli gcc make nodejs npm python3
    # Python
    uv
    # Containers
    podman podman-compose toolbox
)

DESKTOP_PACKAGES=(
    kitty
    # Vietnamese input
    fcitx5 fcitx5-unikey kcm-fcitx5 fcitx5-autostart
    # Btrfs snapshots
    snapper
)

packages=("${CLI_PACKAGES[@]}")
[[ $CLI_ONLY -eq 1 ]] || packages+=("${DESKTOP_PACKAGES[@]}")

info "Installing ${#packages[@]} packages with dnf"
"${SUDO[@]}" dnf install -y "${packages[@]}"

git lfs install --skip-repo >/dev/null

# --- lazygit (not in the Fedora repos; use the upstream release) ---------

install_lazygit() {
    if command -v lazygit >/dev/null 2>&1; then
        info "lazygit already installed"
        return
    fi

    local arch
    case "$(uname -m)" in
        aarch64 | arm64) arch=arm64 ;;
        x86_64) arch=x86_64 ;;
        *)
            warn "No lazygit release for $(uname -m); skipping"
            return
            ;;
    esac

    local version
    version="$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest |
        sed -n 's/.*"tag_name": *"v\([^"]*\)".*/\1/p')"
    if [[ -z "$version" ]]; then
        warn "Could not look up the latest lazygit release; skipping"
        return
    fi

    info "Installing lazygit $version to ~/.local/bin"
    local tmp
    tmp="$(mktemp -d)"
    curl -fsSL -o "$tmp/lazygit.tar.gz" \
        "https://github.com/jesseduffield/lazygit/releases/download/v${version}/lazygit_${version}_Linux_${arch}.tar.gz"
    tar -xzf "$tmp/lazygit.tar.gz" -C "$tmp" lazygit
    mkdir -p "$HOME/.local/bin"
    install -m 755 "$tmp/lazygit" "$HOME/.local/bin/lazygit"
    rm -rf "$tmp"
}

install_lazygit

# --- JetBrains Mono Nerd Font --------------------------------------------

install_font() {
    local dir="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
    if [[ -d "$dir" ]]; then
        info "JetBrains Mono Nerd Font already installed"
        return
    fi
    info "Installing JetBrains Mono Nerd Font"
    mkdir -p "$dir"
    curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz |
        tar -xJ -C "$dir"
    fc-cache -f "$dir" >/dev/null
}

[[ $CLI_ONLY -eq 1 ]] || install_font

# --- tmux plugin manager -------------------------------------------------

TPM_DIR="$HOME/.config/tmux/plugins/tpm"
if [[ -d "$TPM_DIR" ]]; then
    info "TPM already installed"
else
    info "Installing TPM (tmux plugin manager)"
    git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

# --- Oh My Fish + agnoster theme -----------------------------------------

OMF_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fish/omf"
if [[ -d "$OMF_DIR" ]]; then
    info "Oh My Fish already installed"
else
    info "Installing Oh My Fish"
    tmp="$(mktemp)"
    curl -fsSL -o "$tmp" https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install
    fish "$tmp" --noninteractive --yes
    rm -f "$tmp"
    # The OMF installer rewrites conf.d/omf.fish; keep the repo's version.
    git -C "$DOTFILES" checkout -- .config/fish/conf.d/omf.fish 2>/dev/null || true
fi
fish -c 'omf install agnoster; omf theme agnoster' || warn "Could not set the agnoster theme"

info "Done."
if [[ $CLI_ONLY -eq 0 ]]; then
    cat <<'EOF'

Next steps:
  1. ./install.sh                       # link the configs
  2. ./scripts/battery-limit.sh         # optional: charge limit 70-80%
  3. chsh -s /usr/bin/fish              # optional: make fish your login shell
  4. System Settings > Keyboard > Virtual Keyboard > Fcitx 5, then log out and back in
EOF
fi
