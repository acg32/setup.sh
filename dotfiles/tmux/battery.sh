#!/bin/sh

b=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n1)
[ -n "$b" ] || exit 0
[ -r "$b/capacity" ] || exit 0

cap=$(cat "$b/capacity")
status=$(cat "$b/status" 2>/dev/null)
icon="󰁹"

case "$status" in
  Charging) icon="󰂄" ;;
  Discharging) icon="󰂃" ;;
esac

printf "#[fg=#245a55,bg=#c64a86]#[fg=#dedede,bg=#c64a86] %s %s%% #[fg=#c64a86,bg=#6b6a12]" "$icon" "$cap"
