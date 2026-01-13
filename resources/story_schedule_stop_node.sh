#!/usr/bin/env bash
set -euo pipefail

RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
BLUE=$'\033[0;34m'
CYAN=$'\033[0;36m'
YELLOW=$'\033[0;33m'
ORANGE=$'\033[38;5;214m'
RESET=$'\033[0m'

sudo apt-get update
sudo apt-get install -y at
sudo systemctl enable --now atd

echo -e "${CYAN}Current server time:${RESET}"
echo -e "${GREEN}$(date)${RESET}"
echo

read_year() {
    local val num
    while true; do
        read -r -p "${YELLOW}year (4 digits): ${RESET}" val
        if [[ ! "$val" =~ ^[0-9]{4}$ ]]; then
            echo -e "${RED}Please enter a 4-digit year (e.g., 2026).${RESET}"
            continue
        fi
        num=$((10#$val))
        if (( num < 1970 || num > 2099 )); then
            echo -e "${RED}Please enter a year between 1970 and 2099.${RESET}"
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
        read -r -p "${YELLOW}${prompt}${RESET}" val
        if [[ ! "$val" =~ ^[0-9]+$ ]]; then
            echo -e "${RED}Please enter numbers only.${RESET}"
            continue
        fi
        num=$((10#$val))
        if (( num < min || num > max )); then
            echo -e "${RED}Please enter a value between $min and $max.${RESET}"
            continue
        fi
        echo "$num"
        return
    done
}

echo -e "${CYAN}Choose an option:${RESET}"
echo -e "${GREEN}1.${RESET} List scheduled jobs"
echo -e "${GREEN}2.${RESET} Stop and disable story services"
echo -e "${GREEN}3.${RESET} Restart and enable story services"
echo -e "${GREEN}4.${RESET} Remove a scheduled job"
echo -e "${GREEN}5.${RESET} Exit"
read -r -p "${YELLOW}Enter choice (1-5): ${RESET}" ACTION

case "$ACTION" in
    1)
        echo -e "${CYAN}Queued jobs:${RESET}"
        if ! sudo atq; then
            echo -e "${RED}Failed to read job queue.${RESET}"
            exit 1
        fi
        exit 0
        ;;
    2)
        ACTION_LABEL="stop/disable"
        COMMANDS=$'systemctl stop story story-geth\nsystemctl disable story story-geth'
        ;;
    3)
        ACTION_LABEL="restart/enable"
        COMMANDS=$'systemctl daemon-reload\nsystemctl enable story story-geth\nsystemctl restart story story-geth'
        ;;
    4)
        echo -e "${CYAN}Queued jobs:${RESET}"
        if ! sudo atq; then
            echo -e "${RED}Failed to read job queue.${RESET}"
            exit 1
        fi
        echo
        read -r -p "${YELLOW}Enter job ID to remove: ${RESET}" JOB_ID
        if [[ ! "$JOB_ID" =~ ^[0-9]+$ ]]; then
            echo -e "${RED}Invalid job ID.${RESET}"
            exit 1
        fi
        if sudo atrm "$JOB_ID"; then
            echo -e "${GREEN}Removed job ID $JOB_ID.${RESET}"
        else
            echo -e "${RED}Failed to remove job ID $JOB_ID.${RESET}"
            exit 1
        fi
        exit 0
        ;;
    5)
        echo -e "${YELLOW}Exiting.${RESET}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid choice. Exiting.${RESET}"
        exit 1
        ;;
esac

echo
echo -e "${CYAN}This will schedule:${RESET}"
echo -e "${GREEN}$COMMANDS${RESET}"
echo
echo -e "${CYAN}Example input:${RESET}"
echo -e "  ${GREEN}year=2026 month=1 day=13 hour=6 minute=31 second=0${RESET}"
echo -e "${YELLOW}Note:${RESET} you can enter 1 or 2 digits for month/day/hour/minute/second (e.g., 6 or 06)."
echo -e "${YELLOW}Note:${RESET} scheduled jobs run as root because sudo at is used."
echo

Y=$(read_year)
M=$(read_range "month (1-12): " 1 12)
D=$(read_range "day (1-31): " 1 31)
h=$(read_range "hour (24h format, 0-23): " 0 23)
m=$(read_range "minute (0-59): " 0 59)
s=$(read_range "second (0-59): " 0 59)

DT_HUMAN="$(printf "%04d-%02d-%02d %02d:%02d:%02d" "$Y" "$M" "$D" "$h" "$m" "$s")"
DT_AT="$(printf "%04d%02d%02d%02d%02d.%02d" "$Y" "$M" "$D" "$h" "$m" "$s")"
echo -e "${GREEN}Scheduling $ACTION_LABEL at:${RESET} ${CYAN}$DT_HUMAN${RESET}"

echo -e "$COMMANDS\n" | sudo at -t "$DT_AT"

echo
echo -e "${CYAN}Queued jobs:${RESET}"
sudo atq
