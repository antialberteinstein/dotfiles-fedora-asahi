# Contributing

Thanks for taking the time to help. These are personal dotfiles, but fixes
that make them work better on Fedora Asahi, or on more Apple Silicon models,
are very welcome.

## Before you start

- **Bugs:** open an issue with the bug report form. Include your Mac model,
  Fedora Asahi version and the exact command or keys that failed.
- **New features or plugins:** open an issue first so we can agree on it
  before you spend time on a pull request. The goal is a small, maintainable
  setup, so not every addition will fit.
- **Small fixes** (typos, broken links, obvious bugs) can go straight to a
  pull request.

## Making a change

1. Fork the repository and create a branch from `master`:

   | Prefix | For |
   | --- | --- |
   | `feat/` | new behaviour |
   | `fix/` | bug fixes |
   | `docs/` | documentation only |
   | `chore/` | cleanup, no behaviour change |
   | `ci/` | GitHub Actions |

2. Keep the rules the repository already follows:
   - Install packages only from the official Fedora repositories, no COPR.
   - Scripts must be safe to run more than once and must never delete user
     files; back them up instead.
   - Never commit personal data (names, emails, tokens, absolute paths such
     as `/home/<you>`).

3. Write commit messages in the
   [Conventional Commits](https://www.conventionalcommits.org) style, for
   example `fix(nvim): restore treesitter indent for python`.

## Checking your change

CI runs these on every pull request. Running them first saves a round trip.

```sh
# Shell scripts
shellcheck -x install.sh uninstall.sh scripts/*.sh

# Lua formatting
stylua --check .config/nvim tests
```

To check that Neovim starts cleanly, link the config under a test name so
your own setup is not touched:

```sh
ln -s "$PWD/.config/nvim" ~/.config/nvim-test
NVIM_APPNAME=nvim-test nvim --headless "+Lazy! sync" +qa
SMOKE_FULL=1 NVIM_APPNAME=nvim-test nvim --headless -c "luafile tests/nvim-smoke.lua"
rm ~/.config/nvim-test
```

To try the install scripts without touching your system, use a toolbox:

```sh
toolbox create dotfiles-test
toolbox enter dotfiles-test
export HOME=$(mktemp -d)   # a throwaway home inside the toolbox
./install.sh
./scripts/packages.sh --cli-only
```

## Pull requests

- Fill in the pull request template and link the issue it closes.
- Keep each pull request to one topic.
- Describe how you tested it, and on which Mac if it touches hardware.

By contributing you agree that your work is released under the
[MIT License](LICENSE) and that you will follow the
[Code of Conduct](CODE_OF_CONDUCT.md).
