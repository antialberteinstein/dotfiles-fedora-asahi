#!/usr/bin/env bash
# Set up Btrfs snapshots of / with snapper.
#
# Creates a snapper config for the root filesystem and keeps the 10 most
# recent numbered snapshots. Hourly timeline snapshots stay off so the disk
# does not fill up. Take a snapshot before risky changes:
#
#   sudo snapper -c root create -d "before update"
#   sudo snapper -c root list
#
# Usage: ./scripts/snapshots.sh

set -euo pipefail

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
fi

if [[ "$(findmnt -n -o FSTYPE /)" != "btrfs" ]]; then
    echo "/ is not on Btrfs; snapper snapshots need Btrfs." >&2
    exit 1
fi

if ! command -v snapper >/dev/null 2>&1; then
    sudo dnf install -y snapper
fi

if sudo snapper -c root get-config >/dev/null 2>&1; then
    echo "snapper config 'root' already exists"
else
    echo "Creating snapper config 'root' for /"
    sudo snapper -c root create-config /
fi

sudo snapper -c root set-config \
    TIMELINE_CREATE=no \
    NUMBER_CLEANUP=yes \
    NUMBER_LIMIT=10 \
    NUMBER_LIMIT_IMPORTANT=5

# Let your user list snapshots without sudo
sudo snapper -c root set-config ALLOW_USERS="$USER" SYNC_ACL=yes

sudo systemctl enable --now snapper-cleanup.timer

sudo snapper -c root create -d "snapshots.sh: initial snapshot"
echo "Done. Current snapshots:"
snapper -c root list
