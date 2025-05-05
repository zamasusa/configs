#!/bin/bash

PowerState=$(bluetoothctl show | grep Powered | awk '{print $2}')

if [ "$PowerState" = "no" ]; then
  bluetoothctl power on
else
  bluetoothctl power off
fi
