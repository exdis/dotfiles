#!/bin/bash

SPACE_SIDS=(1 2 3 4 5 6 7 8 9 10)

for sid in "${SPACE_SIDS[@]}"
do
  sketchybar --add space space.$sid left                                    \
             --set space.$sid space=$sid                                    \
                              icon=$sid                                     \
                              label.font="sketchybar-app-font:Regular:16.0" \
                              label.padding_right=0                         \
                              label.padding_left=0                          \
                              icon.padding_right=10                         \
                              icon.padding_left=10                          \
                              label.y_offset=-1                             \
                              script="$PLUGIN_DIR/space.sh"
done

