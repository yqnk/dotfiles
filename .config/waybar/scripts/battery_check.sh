#!/bin/zsh

# TODO: add icons

filename_low="/tmp/lowbattery.lock"
filename_critical="/tmp/criticalbattery.lock"

percentage=$(cat /sys/class/power_supply/BAT0/capacity)
is_discharging=$(upower -d | grep 'state' | grep 'discharging' | wc -l) # 0 = charging

if [ "$is_discharging" -eq 0 ]; then
  if [ -f "$filename_low" ]; then
    rm $filename_low
  fi
  if [ -f "$filename_critical" ]; then
    rm $filename_critical
  fi
else
  if [ "$percentage" -eq 5 ] && [ ! -f "$filename_critical" ]; then
    notify-send -u critical "Very low battery" "${percentage}% remaining :("
    touch $filename_critical 
  elif [ "$percentage" -eq 20 ] && [ ! -f "$filename_low" ]; then
    notify-send -u low "Low battery" "${percentage}% remaining :("
    touch $filename_low
  fi
fi

exit 0
