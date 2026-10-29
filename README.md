# dotfiles-fedora-asahi

[![CI](https://github.com/antialberteinstein/dotfiles-fedora-asahi/actions/workflows/ci.yml/badge.svg)](https://github.com/antialberteinstein/dotfiles-fedora-asahi/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Dotfiles for **Fedora Asahi Remix** on Apple Silicon Macs with **KDE Plasma**:
Neovim, fish, kitty, tmux and git, plus scripts that install everything from
the official Fedora repositories.

The configs are symlinked from this repository, so you can edit them in place,
commit, and pull updates on any machine.

<!-- Screenshot: add one at docs/screenshot.png and uncomment the line below.
![Neovim, kitty and fish on Fedora Asahi](docs/screenshot.png)
-->

## What's inside

| Path | What it configures |
| --- | --- |
| `.config/nvim` | Neovim 0.12 with lazy.nvim, LSP, treesitter, Telescope, Neo-tree, Tokyo Night |
| `.config/fish` | fish shell with Oh My Fish and the agnoster theme |
| `.config/kitty` | kitty terminal, JetBrains Mono Nerd Font, Catppuccin Macchiato |
| `.config/tmux` | tmux with TPM, mouse support, `\|` and `-` splits |
| `.config/git` | git with Git LFS; your name and email stay out of the repo |
| `.bashrc` | bash, for when you are not in fish |
| `install.sh` / `uninstall.sh` | link or unlink the configs |
| `scripts/packages.sh` | install the packages these configs need |
| `scripts/battery-limit.sh` | keep the battery between 70% and 80% |

## Requirements

- An Apple Silicon Mac running Fedora Asahi Remix 44 with KDE Plasma
- `git` and `sudo`

Regular Fedora 44 on x86_64 should work too, except for the battery limit,
but Fedora Asahi is the only setup that is tested.

## Install

```sh
git clone https://github.com/antialberteinstein/dotfiles-fedora-asahi.git ~/dotfiles-fedora-asahi
cd ~/dotfiles-fedora-asahi

./install.sh                 # symlink the configs (asks for your git name and email)
./scripts/packages.sh        # packages, fonts, lazygit, TPM, Oh My Fish
./scripts/battery-limit.sh   # optional: charge limit 70-80%
chsh -s /usr/bin/fish        # optional: make fish your login shell
```

Anything already at a target path is moved to `<name>.bak-<timestamp>` before
it is replaced, so nothing is lost. Both scripts are safe to run again.
Use `./install.sh --dry-run` to see what would change first.

Then finish two things by hand:

1. **Vietnamese input (Fcitx5 + Unikey):** System Settings > Keyboard >
   Virtual Keyboard > choose **Fcitx 5**, log out and back in, then add
   **Unikey** under System Settings > Input Method. Switch with `Ctrl+Space`.
2. **Neovim:** start `nvim` once. lazy.nvim installs the plugins, then
   treesitter parsers and language servers download in the background.

### Packages

`scripts/packages.sh` uses only the official Fedora repositories (no COPR):

- **Shell and CLI:** fish, tmux, git, git-lfs, gh, btop, bat, ripgrep, fd-find, wl-clipboard
- **Neovim:** neovim, tree-sitter-cli, gcc, make, nodejs, npm, python3
- **Python:** uv
- **Containers:** podman, podman-compose, toolbox
- **Desktop:** kitty, fcitx5, fcitx5-unikey, kcm-fcitx5, fcitx5-autostart, snapper

It also installs [lazygit](https://github.com/jesseduffield/lazygit) from its
release page (it is not in the Fedora repositories), JetBrains Mono Nerd Font,
TPM and Oh My Fish. Pass `--cli-only` to skip the desktop packages, for
example inside a toolbox.

## Update

```sh
cd ~/dotfiles-fedora-asahi
git pull
```

The configs are symlinks, so changes apply right away. In Neovim, run
`:Lazy sync` to match the plugin versions in `lazy-lock.json`.

## Uninstall

```sh
./uninstall.sh
```

This removes only the symlinks that point into this repository and tells you
where your backups are. Installed packages are left alone.

## Neovim keymaps

The leader key is `Space`. Press it and wait to see every mapping, or press
`?` to search them.

| Keys | Action |
| --- | --- |
| `Space e` | Toggle the file explorer |
| `Space ff` / `Space fg` | Find files / search in files |
| `Space fb` / `Space fr` | Open buffers / recent files |
| `Space fc` / `Space fk` | Commands / keymaps |
| `Ctrl+s` | Save |
| `Ctrl+/` | Toggle comment (also `gcc`, and `gc` on a selection) |
| `Shift+h` / `Shift+l` | Previous / next buffer |
| `Space bd` | Close buffer |
| `Ctrl+\` | Floating terminal |
| `Space gg` | LazyGit |
| `gd` / `K` | Go to definition / hover docs |
| `grr` / `gri` | References / implementations |
| `Space ca` / `Space cr` / `Space cf` | Code action / rename / format |
| `Space xx` | Diagnostics list |
| `]c` / `[c` | Next / previous git hunk |
| `Space hs` / `Space hr` / `Space hp` | Stage / reset / preview hunk |

In [Neovide](https://neovide.dev) the VS Code-style `Super` shortcuts work as
well (`Super+s`, `Super+p`, `Super+b`, `Super+/`, ...). Terminals never
receive `Super`, so they are not mapped there.

## tmux keys

The prefix is the default `Ctrl+b`.

| Keys | Action |
| --- | --- |
| `prefix \|` / `prefix -` | Split side by side / top and bottom |
| `Alt+arrows` | Move between panes |
| `Alt+h/j/k/l` | Resize the pane |
| `Ctrl+Left` / `Ctrl+Right` | Previous / next window |
| `prefix z` | Zoom the pane |
| `prefix g` | LazyGit in a new pane |
| `prefix r` | Reload the config |

## Python with toolbox and uv

Keep the host system clean and do project work in a toolbox:

```sh
toolbox create dev
toolbox enter dev
~/dotfiles-fedora-asahi/scripts/packages.sh --cli-only   # optional: same tools inside

uv init my-project && cd my-project
uv add numpy
uv run python main.py
```

Services such as databases are better run on the host with
`podman compose up -d`; the toolbox shares the host network, so your code
reaches them on `localhost`.

## Apple Silicon notes

- **Charge limit:** KDE's own setting resets to 100% after a reboot on Asahi,
  which is why `scripts/battery-limit.sh` installs a systemd service instead.
  Run `./scripts/battery-limit.sh --disable` to charge to 100% again.
- **Sleep:** suspend works but drains the battery faster than macOS does.
  Shut down for long breaks.
- **Containers:** pick images with an `arm64` variant.

## Contributing

Bug reports and fixes are welcome, especially for other Apple Silicon models.
See [CONTRIBUTING.md](CONTRIBUTING.md) and the
[Code of Conduct](CODE_OF_CONDUCT.md).

## Credits

- Adapted from [antialberteinstein/dotfiles](https://github.com/antialberteinstein/dotfiles).
- [Catppuccin for kitty](https://github.com/catppuccin/kitty) (MIT) and
  [Tokyo Night](https://github.com/folke/tokyonight.nvim) color themes.
- [Asahi Linux](https://asahilinux.org) and the Fedora Asahi SIG for making
  Linux on Apple Silicon possible.

## License

[MIT](LICENSE) © Nhat Nguyen
