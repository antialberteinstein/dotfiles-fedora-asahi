#!/usr/bin/env bash
# Keep the battery between START% and END% on Apple Silicon Macs running
# Asahi Linux, and make the limit survive reboots.
#
# KDE's charge limit setting resets to 100% on reboot with the macsmc-battery
# driver, so this installs a small systemd service that reapplies it at boot.
#
# Usage: ./scripts/battery-limit.sh [START END]   (default: 70 80)
#        ./scripts/battery-limit.sh --disable      (charge to 100% again)

set -euo pipefail

BATTERY=/sys/class/power_supply/macsmc-battery
SERVICE=/etc/systemd/system/battery-limit.service

if [[ "${1:-}" == "--disable" ]]; then
    sudo systemctl disable --now battery-limit.service 2>/dev/null || true
    sudo rm -f "$SERVICE"
    sudo systemctl daemon-reload
    echo 100 | sudo tee "$BATTERY/charge_control_end_threshold" >/dev/null
    echo "Charge limit removed."
    exit 0
fi

START="${1:-70}"
END="${2:-80}"

if [[ ! -e "$BATTERY/charge_control_end_threshold" ]]; then
    echo "No macsmc-battery charge control found. This script is for Apple Silicon Macs on Asahi Linux." >&2
    exit 1
fi

if ! [[ "$START" =~ ^[0-9]+$ && "$END" =~ ^[0-9]+$ ]] || ((START >= END || END > 100)); then
    echo "START and END must be numbers with START < END <= 100." >&2
    exit 1
fi

sudo tee "$SERVICE" >/dev/null <<EOF
[Unit]
Description=Battery charge limit (${START}-${END}%)
ConditionPathExists=$BATTERY/charge_control_end_threshold

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'echo $START > $BATTERY/charge_control_start_threshold; echo $END > $BATTERY/charge_control_end_threshold'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now battery-limit.service
sudo systemctl restart battery-limit.service

echo "Charge limit set: stops at ${END}%, resumes below ${START}%."
echo "Current end threshold: $(cat "$BATTERY/charge_control_end_threshold")"
