#!/bin/bash

# Define Bluetooth sink identifier
BLUETOOTH_SINK="bluez_output"

# Get the current default sink
DEFAULT_SINK=$(pactl get-default-sink)

# Get the current active sink used by applications (Spotify in this case)
ACTUAL_SINK=$(pactl list sink-inputs | grep -A 15 "application.name = \"Spotify\"" | grep 'Sink' | awk '{print $2}' | head -n 1)

# If Spotify is routed to a Bluetooth device, it will use that sink
if [[ -z "$ACTUAL_SINK" ]]; then
    # If Spotify or any application is not using a specific sink, check the default sink
    ACTUAL_SINK=$DEFAULT_SINK
fi

# Handle scroll events to increase or decrease volume
if [[ $1 == "up" ]]; then
    pactl set-sink-volume "$ACTUAL_SINK" +5%
elif [[ $1 == "down" ]]; then
    pactl set-sink-volume "$ACTUAL_SINK" -5%
fi

# Get volume of the current active sink
VOLUME=$(pactl get-sink-volume "$ACTUAL_SINK" | awk '{print $5}' | head -n 1)

# Determine if the active sink is Bluetooth and display volume accordingly
if [[ $ACTUAL_SINK == *"$BLUETOOTH_SINK"* ]]; then
    echo "{\"text\": \"🎧 $VOLUME\", \"tooltip\": \"Bluetooth: $ACTUAL_SINK\"}"
else
    echo "{\"text\": \"🔊 $VOLUME\", \"tooltip\": \"Default: $ACTUAL_SINK\"}"
fi
