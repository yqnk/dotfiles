#!/bin/zsh

current_date=$(date +'%Y-%m-%d_%H:%M:%S')
records_dir="$HOME/documents/records"
mkdir -p $records_dir
wf-recorder -b 0 -c libx264 -p b=5M -g "$(slurp)" -f $records_dir/recording_$current_date.mp4

exit 0
