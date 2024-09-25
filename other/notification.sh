#!/bin/bash

# Function to send notifications
# status: tested
# published by: Deepak Raj
# published on: 2024-08-30

send_notification() {
    notify-send "Notification" "This is a sample notification."
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
    sleep 1  # Adjust the interval as needed
done
