#!/usr/bin/env bash
# Toggle the focused workspace between horizontal (one window per column)
# and vertical (all windows stacked in a single column) layout.
set -euo pipefail

tiled() {
  niri msg --json windows \
    | jq --argjson ws "$1" '[.[] | select(.workspace_id == $ws and .is_floating == false)]'
}

ws=$(niri msg --json windows | jq '[.[] | select(.is_focused)][0].workspace_id')
[ "$ws" = "null" ] && exit 0

windows=$(tiled "$ws")
total=$(jq 'length' <<<"$windows")
columns=$(jq '[.[].layout.pos_in_scrolling_layout[0]] | unique | length' <<<"$windows")

[ "$total" -lt 2 ] && exit 0

if [ "$columns" -eq 1 ]; then
  # Vertical -> horizontal: expel the bottom window until every column holds one.
  for _ in $(seq 1 $((total - 1))); do
    niri msg action focus-column-first
    niri msg action expel-window-from-column
  done
else
  # Horizontal -> vertical: pull everything into the leftmost column.
  niri msg action focus-column-first
  for _ in $(seq 1 $((total - 1))); do
    niri msg action consume-window-into-column
  done
fi
