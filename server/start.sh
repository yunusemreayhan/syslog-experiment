#!/bin/bash

# Replace the receiver hostname in syslog-ng.conf if SYSLOG_RECEIVER is set
if [ -n "$SYSLOG_RECEIVER" ]; then
    echo "Configuring syslog-ng to forward to: $SYSLOG_RECEIVER"
    sed -i "s/syslog-receiver/$SYSLOG_RECEIVER/g" /etc/syslog-ng/syslog-ng.conf
fi

# Trap SIGTERM and SIGINT to gracefully stop syslog-ng
cleanup() {
    echo "Caught signal, shutting down gracefully..."
    if [ -n "$SYSLOG_PID" ]; then
        kill -TERM "$SYSLOG_PID" 2>/dev/null
        wait "$SYSLOG_PID" 2>/dev/null
    fi
    exit 0
}

trap cleanup SIGTERM SIGINT

# Start syslog-ng in the background
echo "Starting syslog-ng..."
/usr/sbin/syslog-ng -F -f /etc/syslog-ng/syslog-ng.conf &
SYSLOG_PID=$!

# Wait for syslog-ng to start
sleep 2

# Check if syslog-ng is running
if ! kill -0 "$SYSLOG_PID" 2>/dev/null; then
    echo "Error: syslog-ng failed to start"
    exit 1
fi

# Run the syslog test program
echo "Starting syslog test program..."
/usr/local/bin/syslog_test

# Keep the container running
echo "Syslog test completed. Keeping syslog-ng running..."
wait "$SYSLOG_PID"
