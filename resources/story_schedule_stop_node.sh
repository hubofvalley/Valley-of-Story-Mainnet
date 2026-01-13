#!/usr/bin/env bash
set -euo pipefail

sudo apt-get update
sudo apt-get install -y at
sudo systemctl enable --now atd

read_year() {
    local val num
    while true; do
        read -r -p "year (4 digits): " val
        if [[ ! "$val" =~ ^[0-9]{4}$ ]]; then
            echo "Please enter a 4-digit year (e.g., 2026)."
            continue
        fi
        num=$((10#$val))
        if (( num < 1970 || num > 2099 )); then
            echo "Please enter a year between 1970 and 2099."
            continue
        fi
        echo "$num"
        return
    done
}

read_range() {
    local prompt=$1
    local min=$2
    local max=$3
    local val num
    while true; do
        read -r -p "$prompt" val
        if [[ ! "$val" =~ ^[0-9]+$ ]]; then
            echo "Please enter numbers only."
            continue
        fi
        num=$((10#$val))
        if (( num < min || num > max )); then
            echo "Please enter a value between $min and $max."
            continue
        fi
        echo "$num"
        return
    done
}

echo "Choose action to schedule:"
echo "1. Stop and disable story services"
echo "2. Restart and enable story services"
echo "3. Exit"
read -r -p "Enter choice (1-3): " ACTION

case "$ACTION" in
    1)
        ACTION_LABEL="stop/disable"
        COMMANDS=$'systemctl stop story story-geth\nsystemctl disable story story-geth'
        ;;
    2)
        ACTION_LABEL="restart/enable"
        COMMANDS=$'systemctl daemon-reload\nsystemctl enable story story-geth\nsystemctl restart story story-geth'
        ;;
    3)
        echo "Exiting."
        exit 0
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo
echo "This will schedule:"
echo -e "$COMMANDS"
echo
echo "Example input:"
echo "  year=2026 month=1 day=13 hour=6 minute=31 second=0"
echo "Note: you can enter 1 or 2 digits for month/day/hour/minute/second (e.g., 6 or 06)."
echo "Note: scheduled jobs run as root because sudo at is used."
echo

Y=$(read_year)
M=$(read_range "month (1-12): " 1 12)
D=$(read_range "day (1-31): " 1 31)
h=$(read_range "hour (24h format, 0-23): " 0 23)
m=$(read_range "minute (0-59): " 0 59)
s=$(read_range "second (0-59): " 0 59)

DT_HUMAN="$(printf "%04d-%02d-%02d %02d:%02d:%02d" "$Y" "$M" "$D" "$h" "$m" "$s")"
DT_AT="$(printf "%04d%02d%02d%02d%02d.%02d" "$Y" "$M" "$D" "$h" "$m" "$s")"
echo "Scheduling $ACTION_LABEL at: $DT_HUMAN"

echo -e "$COMMANDS\n" | sudo at -t "$DT_AT"

echo
echo "Queued jobs:"
sudo atq
