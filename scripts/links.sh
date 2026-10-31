# shellcheck shell=bash
# The configs and commands that install.sh links and uninstall.sh removes.
# Each entry is "<path in this repo>:<path under $HOME>".
# Expects DOTFILES to be set by the script that sources this file.
# shellcheck disable=SC2034  # used by the scripts that source this file
LINKS=(
    ".bashrc:.bashrc"
    ".config/fish:.config/fish"
    ".config/kitty:.config/kitty"
    ".config/nvim:.config/nvim"
    ".config/tmux:.config/tmux"
    ".config/git/config:.config/git/config"
)

# Commands in .local/bin are linked one by one, because ~/.local/bin also
# holds programs installed by other tools (lazygit, claude...).
for _cmd in "$DOTFILES"/.local/bin/*; do
    if [[ -f "$_cmd" ]]; then
        LINKS+=(".local/bin/${_cmd##*/}:.local/bin/${_cmd##*/}")
    fi
done
unset _cmd
