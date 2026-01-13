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
    local __var=$1
    local val num
    while true; do
        read -r -p "${YELLOW}year (4 digits, or type 'back' to return to main menu): ${RESET}" val
        if [[ "${val,,}" == "back" ]]; then
            return 2
        fi
        if [[ ! "$val" =~ ^[0-9]{4}$ ]]; then
            echo -e "${RED}Please enter a 4-digit year (e.g., 2026).${RESET}"
            continue
        fi
        num=$((10#$val))
        if (( num < 1970 || num > 2099 )); then
            echo -e "${RED}Please enter a year between 1970 and 2099.${RESET}"
            continue
        fi
        printf -v "$__var" "%s" "$num"
        return 0
    done
}

read_range() {
    local __var=$1
    local prompt=$2
    local min=$3
    local max=$4
    local val num
    while true; do
        read -r -p "${YELLOW}${prompt} (or type 'back' to return to main menu): ${RESET}" val
        if [[ "${val,,}" == "back" ]]; then
            return 2
        fi
        if [[ ! "$val" =~ ^[0-9]+$ ]]; then
            echo -e "${RED}Please enter numbers only.${RESET}"
            continue
        fi
        num=$((10#$val))
        if (( num < min || num > max )); then
            echo -e "${RED}Please enter a value between $min and $max.${RESET}"
            continue
        fi
        printf -v "$__var" "%s" "$num"
        return 0
    done
}

pause_return() {
    read -r -p "${YELLOW}Press Enter to return to the schedule menu...${RESET}"
}

list_jobs() {
    echo -e "${CYAN}Queued jobs:${RESET}"
    if ! sudo atq; then
        echo -e "${RED}Failed to read job queue.${RESET}"
        return 1
    fi
}

schedule_jobs() {
    local action_label=$1
    local commands=$2
    local Y M D h m s
    echo
    echo -e "${CYAN}This will schedule:${RESET}"
    echo -e "${GREEN}$commands${RESET}"
    echo
    echo -e "${CYAN}Example input:${RESET}"
    echo -e "  ${GREEN}year=2026 month=1 day=13 hour=6 minute=31 second=0${RESET}"
    echo -e "${YELLOW}Note:${RESET} you can enter 1 or 2 digits for month/day/hour/minute/second (e.g., 6 or 06)."
    echo -e "${YELLOW}Note:${RESET} scheduled jobs run as root because sudo at is used."
    echo

    if ! read_year Y; then
        return 2
    fi
    if ! read_range M "month (1-12)" 1 12; then
        return 2
    fi
    if ! read_range D "day (1-31)" 1 31; then
        return 2
    fi
    if ! read_range h "hour (24h format, 0-23)" 0 23; then
        return 2
    fi
    if ! read_range m "minute (0-59)" 0 59; then
        return 2
    fi
    if ! read_range s "second (0-59)" 0 59; then
        return 2
    fi

    DT_HUMAN="$(printf "%04d-%02d-%02d %02d:%02d:%02d" "$Y" "$M" "$D" "$h" "$m" "$s")"
    DT_AT="$(printf "%04d%02d%02d%02d%02d.%02d" "$Y" "$M" "$D" "$h" "$m" "$s")"
    echo -e "${GREEN}Scheduling $action_label at:${RESET} ${CYAN}$DT_HUMAN${RESET}"

    echo -e "$commands\n" | sudo at -t "$DT_AT"
    echo
    if ! list_jobs; then
        return 1
    fi
}

while true; do
    echo -e "${CYAN}Choose an option:${RESET}"
    echo -e "${GREEN}1.${RESET} List scheduled jobs"
    echo -e "${GREEN}2.${RESET} Stop and disable story services"
    echo -e "${GREEN}3.${RESET} Restart and enable story services"
    echo -e "${GREEN}4.${RESET} Remove a scheduled job"
    echo -e "${GREEN}5.${RESET} Exit"
    read -r -p "${YELLOW}Enter choice (1-5): ${RESET}" ACTION

    case "$ACTION" in
        1)
            if ! list_jobs; then
                pause_return
                continue
            fi
            pause_return
            ;;
        2)
            if ! schedule_jobs "stop/disable" $'systemctl stop story story-geth\nsystemctl disable story story-geth'; then
                rc=$?
                if (( rc == 2 )); then
                    echo -e "${YELLOW}Returning to main menu...${RESET}"
                    exit 0
                fi
                pause_return
                continue
            fi
            pause_return
            ;;
        3)
            if ! schedule_jobs "restart/enable" $'systemctl daemon-reload\nsystemctl enable story story-geth\nsystemctl restart story story-geth'; then
                rc=$?
                if (( rc == 2 )); then
                    echo -e "${YELLOW}Returning to main menu...${RESET}"
                    exit 0
                fi
                pause_return
                continue
            fi
            pause_return
            ;;
        4)
            if ! list_jobs; then
                pause_return
                continue
            fi
            echo
            read -r -p "${YELLOW}Enter job ID to remove: ${RESET}" JOB_ID
            if [[ ! "$JOB_ID" =~ ^[0-9]+$ ]]; then
                echo -e "${RED}Invalid job ID.${RESET}"
                pause_return
                continue
            fi
            if sudo atrm "$JOB_ID"; then
                echo -e "${GREEN}Removed job ID $JOB_ID.${RESET}"
            else
                echo -e "${RED}Failed to remove job ID $JOB_ID.${RESET}"
            fi
            pause_return
            ;;
        5)
            echo -e "${YELLOW}Exiting.${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice. Try again.${RESET}"
            pause_return
            ;;
    esac
done
