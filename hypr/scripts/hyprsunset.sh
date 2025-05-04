#!/bin/bash

set -e

# ---- CONFIG ----
LAT="42.2411"
LON="-83.6130"
MIN_TEMP=2000
MAX_TEMP=4000
INTERVAL=5m
SUN_API="https://api.sunrise-sunset.org/json?lat=$LAT&lng=$LON&formatted=0"

# ---- FETCH SUN TIMES ONCE ----
echo "Fetching sunrise/sunset times..."

SUN_DATA=$(curl -s "$SUN_API")

SUNRISE_UTC=$(echo "$SUN_DATA" | jq -r '.results.sunrise')
SUNSET_UTC=$(echo "$SUN_DATA" | jq -r '.results.sunset')

SUNRISE_SEC=$(date -d "$SUNRISE_UTC" +%s)
SUNSET_SEC=$(date -d "$SUNSET_UTC" +%s)

echo "Sunrise (local): $(date -d @$SUNRISE_SEC)"
echo "Sunset  (local): $(date -d @$SUNSET_SEC)"

# ---- FUNCTION ----
adjust_temp() {
    NOW_SEC=$(date +%s)

    if (( NOW_SEC <= SUNRISE_SEC || NOW_SEC >= SUNSET_SEC )); then
        TEMP=$MIN_TEMP
    else
        DAY_DURATION=$(echo "$SUNSET_SEC - $SUNRISE_SEC" | bc)
        ELAPSED=$(echo "$NOW_SEC - $SUNRISE_SEC" | bc)
        FRACTION=$(echo "$ELAPSED / $DAY_DURATION" | bc -l)

        PI=3.14159265
        ANGLE=$(echo "$FRACTION * $PI" | bc -l)
        COS_CURVE=$(echo "c($ANGLE - $PI)" | bc -l)
        NORMALIZED=$(echo "($COS_CURVE + 1) / 2" | bc -l)

        TEMP=$(echo "$MIN_TEMP + ($MAX_TEMP - $MIN_TEMP) * $NORMALIZED" | bc -l)
    fi

    TEMP_INT=$(printf "%.0f" "$TEMP")
    echo "[$(date)] Applying temp: $TEMP_INT K"
    hyprctl hyprsunset temperature $TEMP_INT
}

# ---- LOOP ----
while true; do
    adjust_temp
    sleep "$INTERVAL"
done

