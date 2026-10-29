# agnoster theme options (the theme itself is installed by scripts/packages.sh)
set -g theme_powerline_fonts no
set -g theme_nerd_fonts yes

# User binaries (lazygit, helper scripts linked by install.sh)
fish_add_path -g $HOME/.local/bin

set -gx EDITOR nvim

if status is-interactive
    # Commands to run in interactive sessions can go here
end
