#!/bin/bash

# Function to send notifications
# status: tested
# published by: Deepak Raj
# published on: 2024-08-30

send_notification() {
    notify-send "Notification" "You Have been hacked"
}

# Function to handle termination
cleanup() {
    echo "Stopping notifications."
    exit 0
}

# Trap SIGINT (Ctrl+C) and SIGQUIT (Ctrl+\) signals to handle user interruption
trap cleanup SIGINT SIGQUIT

echo "Press Ctrl + Q to stop notifications."

# Loop to send notifications continuously
while true; do  
    send_notification
    sleep 10  # Adjust the interval as needed
done
