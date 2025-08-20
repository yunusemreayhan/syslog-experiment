#!/bin/bash

# Trap SIGTERM and SIGINT to gracefully stop rsyslogd
cleanup() {
    echo "Caught signal, shutting down rsyslogd gracefully..."
    if [ -n "$RSYSLOG_PID" ]; then
        kill -TERM "$RSYSLOG_PID" 2>/dev/null
        # Give rsyslogd time to shutdown gracefully
        timeout 5 tail --pid="$RSYSLOG_PID" -f /dev/null 2>/dev/null
        # If still running, force kill
        if kill -0 "$RSYSLOG_PID" 2>/dev/null; then
            echo "rsyslogd didn't stop gracefully, forcing shutdown..."
            kill -KILL "$RSYSLOG_PID" 2>/dev/null
        fi
    fi
    exit 0
}

trap cleanup SIGTERM SIGINT

# Start rsyslogd in the background
echo "Starting rsyslogd..."
/usr/sbin/rsyslogd -n -f /etc/rsyslog.conf &
RSYSLOG_PID=$!

# Wait for rsyslogd to start
sleep 2

# Check if rsyslogd is running
if ! kill -0 "$RSYSLOG_PID" 2>/dev/null; then
    echo "Error: rsyslogd failed to start"
    exit 1
fi

echo "rsyslogd started successfully with PID $RSYSLOG_PID"
echo "Waiting for logs..."

# Keep the container running and wait for rsyslogd
wait "$RSYSLOG_PID"
