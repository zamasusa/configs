#!/bin/bash

status=$(systemctl --user show hyprsunset-adjust.service | grep ActiveState= | sed 's/.*=//')


if [[ "$status" == "active" ]]; then
  systemctl --user stop hyprsunset-adjust.service
  hyprctl hyprsunset temperature 6000
else
  systemctl --user start hyprsunset-adjust.service
fi
