# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
  PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

export EDITOR=nvim

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
  for rc in ~/.bashrc.d/*; do
    if [ -f "$rc" ]; then
      . "$rc"
    fi
  done
fi
unset rc

# In kitty, hand over to fish. Bash stays the login shell everywhere else
# (Konsole, TTYs, scripts), and running `bash` from fish keeps you in bash.
if [[ $- == *i* && -n "${KITTY_WINDOW_ID:-}" && -z "${BASH_EXECUTION_STRING:-}" ]] &&
  command -v fish >/dev/null 2>&1 &&
  [[ "$(cat "/proc/$PPID/comm" 2>/dev/null)" != fish ]]; then
  if shopt -q login_shell; then
    exec fish --login
  fi
  exec fish
fi
