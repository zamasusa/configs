#!/bin/bash

# ---- Config ----
LAT="0.7372463" # in radians
MIN_TEMP=1200
MAX_TEMP=4000
INTERVAL=300    # In seconds


# Get solar declination angle δ (in radians)
get_declination() {
    echo "s(-0.4091052) * c((360 / 365) * ($(date +%j) + 10))" | bc -l
}

# Get hour angle h (in radians)
get_hour_angle() {
    echo "0.2617994 * ($(date +%H) - 12)" | bc -l
}

# Main elevation calculation
get_solar_elevation() {
    local phi=$LAT
    local delta=$(get_declination)
    local H=$(get_hour_angle)

    sinA=$(echo "s($phi) * s($delta) + c($phi) * c($delta) * c($H)" | bc -l) 
    # Compute solar elevation using bc
    elevation=$(echo "scale=10; s($delta) * s($phi) + c($delta) * c($phi) * c($H)" | bc -l)

    # Calculate asin and convert to degrees
    asin=$(echo "scale=10; a($elevation)" | bc -l)
    elevation_deg=$(echo "$asin * 180 / (a(1) * 4)" | bc -l)

    # Return the elevation in degrees
    echo "$elevation_deg"
}

# Temperature from elevation
get_temperature_from_elevation() {
    local elevation=$1
    if (( $(echo "$elevation <= 0" | bc -l) )); then
        echo "$MIN_TEMP"
        return
    fi

    local norm=$(echo "$elevation / 90" | bc -l)
    (( $(echo "$norm > 1" | bc -l) )) && norm=1
    (( $(echo "$norm < 0" | bc -l) )) && norm=0

    echo $(printf "%.0f" $(echo "$MIN_TEMP + ($MAX_TEMP - $MIN_TEMP) * $norm" | bc -l))
}

# Loop
while true; do
    elevation=$(get_solar_elevation)
    temp=$(get_temperature_from_elevation "$elevation")
    echo "[$(date)] Elevation: $elevation°, Temp: $temp"
    hyprctl hyprsunset temperature "$temp"
    sleep "$INTERVAL"
done

