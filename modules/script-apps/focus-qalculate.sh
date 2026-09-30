#!/bin/bash

# TODO: float any tiled instances

[ "$(pidof qalculate-gtk)" == "" ] && qalculate-gtk && exit 0
hyprctl dispatch movetoworkspace +0, "class:^(qalculate-gtk)$"
SIZES=$(hyprctl clients -j | jq -r '.[] | select(.class == "qalculate-gtk") | .size | "\(.[0]) \(.[1])"')
CURSOR=$(hyprctl cursorpos | sed 's/,//')
EXACT=$(printf "$CURSOR $SIZES" | awk '{print int($1-$3/2),int($2-$4/2)}')
hyprctl dispatch movewindowpixel "exact $EXACT,class:^(qalculate-gtk)$"
hyprctl dispatch focuswindow "class:^(qalculate-gtk)$"

# DEBUG:
# hyprctl dispatch movewindowpixel "exact $(hyprctl cursorpos | sed 's/,//' | awk '{print int($1/2),int($2/2)}'),class:^(qalculate-gtk)$"
# echo $SIZES
# echo $CURSOR
# echo $EXACT
# echo $(printf "$CURSOR $SIZES" | awk '{print $1,$2,$3,$4,$5}')

