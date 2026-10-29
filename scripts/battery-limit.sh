#!/usr/bin/env bash
# Set the battery charge limit on Apple Silicon Macs running Asahi Linux.
#
# Persistence is handled by Fedora's asahi-battery package (from the Asahi
# project): it saves charge_control_end_threshold whenever it changes and
# restores it at boot. So the limit you set here, or in KDE System Settings
# > Power Management, survives reboots.
#
# Usage: ./scripts/battery-limit.sh [END]     (default: 80)
#        ./scripts/battery-limit.sh --disable  (charge to 100% again)

set -euo pipefail

BATTERY=/sys/class/power_supply/macsmc-battery
THRESHOLD="$BATTERY/charge_control_end_threshold"
OLD_SERVICE=/etc/systemd/system/battery-limit.service

case "${1:-}" in
    --disable) END=100 ;;
    -h | --help)
        sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'
        exit 0
        ;;
    *) END="${1:-80}" ;;
esac

if [[ ! -e "$THRESHOLD" ]]; then
    echo "No macsmc-battery charge control found. This script is for Apple Silicon Macs on Asahi Linux." >&2
    exit 1
fi

if ! [[ "$END" =~ ^[0-9]+$ ]] || ((END < 50 || END > 100)); then
    echo "END must be a number from 50 to 100." >&2
    exit 1
fi

if ! rpm -q asahi-battery >/dev/null 2>&1; then
    echo "Installing asahi-battery so the limit survives reboots"
    sudo dnf install -y asahi-battery
fi

# Remove the service that older versions of this script installed; it would
# overwrite the limit at every boot.
if [[ -f "$OLD_SERVICE" ]]; then
    echo "Removing the old battery-limit.service"
    sudo systemctl disable --now battery-limit.service 2>/dev/null || true
    sudo rm -f "$OLD_SERVICE"
    sudo systemctl daemon-reload
fi

echo "$END" | sudo tee "$THRESHOLD" >/dev/null

actual="$(cat "$THRESHOLD")"
if [[ "$actual" != "$END" ]]; then
    echo "The driver accepted $actual% instead of $END%." >&2
fi
if ((actual >= 100)); then
    echo "Charge limit removed: the battery charges to 100%."
else
    echo "Charge limit set: charging stops at ${actual}%."
fi
