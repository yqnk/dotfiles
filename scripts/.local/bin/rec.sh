#!/bin/sh
# Region recording. Run again to stop the current one.

pkill -INT -x wf-recorder && exit 0

records_dir="$HOME/documents/records"
mkdir -p "$records_dir"

region=$(slurp) || exit 0
exec wf-recorder -b 0 -c libx264 -p b=5M -g "$region" -f "$records_dir/recording_$(date +'%Y-%m-%d_%H:%M:%S').mp4"
