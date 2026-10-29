# Prompt: Oh My Fish with the agnoster theme (conf.d/omf.fish).
# Colors: Tokyo Night (conf.d/tokyonight.fish).

# lazygit and other user binaries
fish_add_path -g $HOME/.local/bin

set -gx EDITOR nvim

if status is-interactive
    # Abbreviations expand when you press Space, so you still see the command
    abbr -a vim nvim
    abbr -a g git
    abbr -a lg lazygit

    # eza: ls with icons and git status
    if type -q eza
        abbr -a ls eza --icons --group-directories-first
        abbr -a ll eza -l --icons --git --group-directories-first
        abbr -a la eza -la --icons --git --group-directories-first
        abbr -a lt eza --tree --level=2 --icons
    end

    # zoxide: `z proj` jumps to the most used directory matching "proj"
    if type -q zoxide
        zoxide init fish | source
    end

    # fzf: Ctrl+R history, Alt+C change directory, Alt+F pick a file.
    # (fzf's usual Ctrl+T is taken by kitty for new tabs.)
    if type -q fzf
        fzf --fish | source
        bind \ef fzf-file-widget
    end
end
