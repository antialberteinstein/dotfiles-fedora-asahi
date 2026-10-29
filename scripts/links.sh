# shellcheck shell=bash
# The configs that install.sh links and uninstall.sh removes.
# Each entry is "<path in this repo>:<path under $HOME>".
# shellcheck disable=SC2034  # used by the scripts that source this file
LINKS=(
    ".bashrc:.bashrc"
    ".config/fish:.config/fish"
    ".config/kitty:.config/kitty"
    ".config/nvim:.config/nvim"
    ".config/tmux:.config/tmux"
    ".config/git/config:.config/git/config"
)
