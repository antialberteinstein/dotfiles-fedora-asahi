# dotfiles-fedora-asahi

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Dotfiles for **Fedora Asahi Remix** on Apple Silicon Macs with **KDE Plasma**:
Neovim, fish, kitty, tmux and git in one **Tokyo Night** theme, plus scripts
that install and update everything from the official Fedora repositories.

The configs are symlinked from this repository, so you can edit them in place,
commit, and pull updates on any machine.

<!-- Screenshot: add one at docs/screenshot.png and uncomment the line below.
![Neovim, kitty and fish on Fedora Asahi](docs/screenshot.png)
-->

## What's inside

| Path | What it configures |
| --- | --- |
| `.config/nvim` | Neovim 0.12 with lazy.nvim, LSP, treesitter, blink.cmp, format on save, Telescope, Neo-tree |
| `.config/fish` | fish with Oh My Fish (agnoster prompt), zoxide, fzf and eza; started from bash inside kitty |
| `.config/kitty` | kitty terminal, JetBrains Mono Nerd Font, translucent background |
| `.config/tmux` | tmux with a Tokyo Night status bar, vim-tmux-navigator and a LazyGit popup |
| `.config/git` | git with Git LFS; your name and email stay out of the repo |
| `.bashrc` | bash, the login shell; hands over to fish inside kitty |
| `install.sh` / `uninstall.sh` | link or unlink the configs |
| `update.sh` | pull the latest version and update configs, packages and plugins |
| `scripts/packages.sh` | install the packages these configs need |
| `scripts/battery-limit.sh` | stop charging at 80% (or any limit you choose) |
| `scripts/snapshots.sh` | Btrfs snapshots of `/` with snapper |

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
./scripts/battery-limit.sh   # optional: stop charging at 80%
./scripts/snapshots.sh       # optional: Btrfs snapshots with snapper
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

- **Shell and CLI:** fish, tmux, git, git-lfs, gh, btop, bat, ripgrep, fd-find, fzf, zoxide, eza, wl-clipboard
- **Neovim:** neovim, tree-sitter-cli, gcc, make, nodejs, npm, python3
- **C/C++:** gcc-c++, clang-tools-extra (clangd)
- **Python:** uv
- **Containers:** podman, podman-compose, toolbox
- **Desktop:** kitty, fcitx5, fcitx5-unikey, kcm-fcitx5, fcitx5-autostart, snapper, asahi-battery

It also installs [lazygit](https://github.com/jesseduffield/lazygit) from its
release page (it is not in the Fedora repositories), JetBrains Mono Nerd Font,
TPM with the tmux plugins, and Oh My Fish. Only missing packages are installed,
so running it again is quick and skips `sudo` when nothing is missing. Pass
`--cli-only` to skip the desktop packages, for example inside a toolbox.

### Shells

Bash stays your login shell, so Konsole, TTYs and scripts use bash as
usual. Opening **kitty** starts bash, and `.bashrc` immediately switches to
fish with `exec fish`. The same happens in tmux and Neovim terminals opened
inside kitty. Type `bash` in fish when you need bash; it stays bash.

In fish:

| Command | What it does |
| --- | --- |
| `z proj` | Jump to the most used directory matching "proj" (zoxide) |
| `Ctrl+R` / `Alt+C` / `Alt+F` | Search history / change directory / pick a file (fzf) |
| `ls`, `ll`, `la`, `lt` | eza listings with icons, git status and a tree view |
| `vim`, `g`, `lg` | Expand to `nvim`, `git`, `lazygit` |
| `Alt+Backspace` | Delete the previous word (`Ctrl+W` closes the kitty tab) |

## Update

```sh
cd ~/dotfiles-fedora-asahi
./update.sh
```

It pulls the latest version (fast-forward only, and stops if you have local
changes in the way), lists the new commits, links any new configs, installs
missing packages, moves Neovim plugins to the versions in `lazy-lock.json`,
updates treesitter parsers and language servers, and syncs tmux plugins.
Already pulled? Use `./update.sh --no-pull`. Add `--skip-packages` to leave
system packages alone.

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
| `Ctrl+h/j/k/l` | Move between splits, and tmux panes inside tmux |
| `Space w…` | Window commands, like `Ctrl+W` (`Space wv` split, `Space wq` close, `Space w=` equalize) |
| `Space v` | Visual block mode (`Ctrl+V`) |
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
| `gd` / `K` / `Ctrl+O` | Go to definition / hover docs / jump back |
| `grr` / `gri` | References / implementations |
| `Space ca` / `Space cr` / `Space cf` | Code action / rename / format |
| `Space uf` | Toggle format on save |
| `Space xx` | Diagnostics list |
| `]c` / `[c` | Next / previous git hunk |
| `Space hs` / `Space hr` / `Space hp` | Stage / reset / preview hunk |
| `Space pp` / `Space pr` | Receive a problem / run its test cases (competitest) |
| `Space pa` / `Space pe` | Add / edit a test case |

Completion: `Enter` accepts, `Tab`/`Shift+Tab` move through the list and
snippet fields, `Ctrl+Space` opens the menu.

Files are formatted on save: Python with ruff, Lua with stylua, web files with
prettier, C/C++ with clangd. Language servers: lua_ls, pyright, ruff, html,
cssls, jsonls, ts_ls, tailwindcss, and clangd (from Fedora; assumes C++17).

**Competitive programming:** install the
[Competitive Companion](https://github.com/jmerle/competitive-companion)
browser extension, press `Space pp` in Neovim, then click the extension on a
Codeforces (or other judge) problem. `Space pr` compiles with
`g++ -std=c++17 -O2` and runs every test case.

**Keys kitty keeps:** `Ctrl+T` new tab, `Ctrl+W` close tab, `Ctrl+V` paste,
`Ctrl+Q` quit, `Ctrl+C` copy when text is selected. That is why Neovim uses
`Space w`, `Space v`, `Alt+V` (insert a key literally) and `Ctrl+O` instead.

In [Neovide](https://neovide.dev) the VS Code-style `Super` shortcuts work as
well (`Super+s`, `Super+p`, `Super+b`, `Super+/`, ...). Terminals never
receive `Super`, so they are not mapped there.

## tmux keys

The prefix is the default `Ctrl+b`.

| Keys | Action |
| --- | --- |
| `prefix \|` / `prefix -` | Split side by side / top and bottom (in the current directory) |
| `Ctrl+h/j/k/l` or `Alt+arrows` | Move between panes (and Neovim splits) |
| `prefix H/J/K/L` | Resize the pane; keep pressing to repeat |
| `prefix n` / `prefix p` | Next / previous window |
| `prefix z` | Zoom the pane |
| `prefix g` | LazyGit in a popup |
| `prefix Ctrl+l` | Clear the screen (`Ctrl+l` moves between panes) |
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

- **Charge limit:** Fedora's `asahi-battery` package saves the limit
  whenever it changes and restores it at boot, so you can set it in
  System Settings > Power Management or with `./scripts/battery-limit.sh 80`.
  Run `./scripts/battery-limit.sh --disable` to charge to 100% again.
- **Snapshots:** after `./scripts/snapshots.sh`, take one before risky
  changes with `sudo snapper -c root create -d "before update"` and list
  them with `snapper -c root list`.
- **Sleep:** suspend works but drains the battery faster than macOS does.
  Shut down for long breaks.
- **Containers:** pick images with an `arm64` variant.

## Contributing

Bug reports and fixes are welcome, especially for other Apple Silicon models.
See [CONTRIBUTING.md](CONTRIBUTING.md) and the
[Code of Conduct](CODE_OF_CONDUCT.md).

## Credits

- Adapted from [antialberteinstein/dotfiles](https://github.com/antialberteinstein/dotfiles).
- [Tokyo Night](https://github.com/folke/tokyonight.nvim) by Folke Lemaitre
  (MIT): the Neovim theme and its kitty, tmux and fish color files.
- [Asahi Linux](https://asahilinux.org) and the Fedora Asahi SIG for making
  Linux on Apple Silicon possible.

## License

[MIT](LICENSE) © Nhat Nguyen
