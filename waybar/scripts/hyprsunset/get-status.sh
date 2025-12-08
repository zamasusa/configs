#!/bin/bash

status=$(systemctl --user show hyprsunset-adjust.service | grep ActiveState= | sed 's/.*=//')

active=""
inactive="󱩷"

val=$inactive
if [[ "$status" == "active" ]]; then
  val=$active
fi

echo { \"text\": \"$val\" }
