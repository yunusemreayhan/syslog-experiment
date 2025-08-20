#!/bin/bash

# Verification script for syslog functionality

echo "=== Syslog Functionality Verification ==="
echo ""

# Check if containers are running
echo "1. Checking container status..."
if podman-compose ps | grep -q "Up"; then
    echo "✓ Containers are running"
else
    echo "✗ Containers are not running. Please run 'make up' first."
    exit 1
fi

echo ""
echo "2. Sending test messages..."

# Send test messages using nc (netcat)
echo "<14>Test message 1: INFO level from verification script" | nc -u -w1 localhost 5515
sleep 1
echo "<11>Test message 2: ERROR level from verification script" | nc -u -w1 localhost 5515
sleep 1
echo "<12>Test message 3: WARNING level from verification script" | nc -u -w1 localhost 5515

echo "✓ Test messages sent"

echo ""
echo "3. Waiting for logs to be processed..."
sleep 3

echo ""
echo "4. Checking receiver logs..."

# Check if receiver logs exist
RECEIVER_LOG_DIR="receiver/logs"
if [ -d "$RECEIVER_LOG_DIR/remote" ]; then
    echo "✓ Receiver log directory exists"
    
    # List log files
    echo ""
    echo "Log files found:"
    find "$RECEIVER_LOG_DIR" -name "*.log" -type f | while read -r file; do
        echo "  - $file"
        if [ -s "$file" ]; then
            echo "    Size: $(stat -c%s "$file") bytes"
            echo "    Last 3 lines:"
            tail -3 "$file" | sed 's/^/      /'
        fi
    done
else
    echo "✗ No receiver logs found"
fi

echo ""
echo "5. Checking server logs..."

# Check server logs
SERVER_LOG_DIR="server/logs"
if [ -d "$SERVER_LOG_DIR" ] && [ "$(ls -A $SERVER_LOG_DIR)" ]; then
    echo "✓ Server log directory has files"
    
    # Check for syslog_test.log
    if [ -f "$SERVER_LOG_DIR/syslog_test.log" ]; then
        echo "✓ syslog_test.log exists"
        echo "  Size: $(stat -c%s "$SERVER_LOG_DIR/syslog_test.log") bytes"
        echo "  Last 3 lines:"
        tail -3 "$SERVER_LOG_DIR/syslog_test.log" | sed 's/^/    /'
    fi
else
    echo "✗ No server logs found"
fi

echo ""
echo "=== Verification Complete ==="
echo ""
echo "Tips:"
echo "- Use 'make logs' to see real-time container logs"
echo "- Use 'make check-files' to list all log files"
echo "- Check 'receiver/logs/remote/' for received logs organized by hostname"
