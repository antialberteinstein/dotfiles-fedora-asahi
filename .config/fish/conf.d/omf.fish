# Path to Oh My Fish install.
# (the installer's default location; scripts/packages.sh installs it there)
set -q XDG_DATA_HOME
  and set -gx OMF_PATH "$XDG_DATA_HOME/omf"
  or set -gx OMF_PATH "$HOME/.local/share/omf"

# Load Oh My Fish configuration (skipped until scripts/packages.sh installs it).
test -f $OMF_PATH/init.fish; and source $OMF_PATH/init.fish
