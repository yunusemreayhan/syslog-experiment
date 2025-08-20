#!/bin/bash

# Example script showing how to send custom syslog messages

echo "=== Custom Syslog Message Examples ==="
echo ""
echo "This script demonstrates different ways to send syslog messages."
echo ""

# Check if receiver is accessible
if ! nc -zv localhost 5515 2>/dev/null; then
    echo "Error: Syslog receiver is not accessible on localhost:5515"
    echo "Please ensure the containers are running: make up"
    exit 1
fi

# Function to send syslog message with proper format
send_syslog() {
    local priority=$1
    local tag=$2
    local message=$3
    
    # Syslog format: <priority>timestamp hostname tag: message
    echo "<${priority}>$(date '+%b %d %H:%M:%S') $(hostname) ${tag}: ${message}" | nc -u -w1 localhost 5515
}

echo "1. Sending messages with different priorities..."
echo ""

# Priority = Facility * 8 + Severity
# Facility 16 (local0) = 16 * 8 = 128
# Common severities:
# 0=Emergency, 1=Alert, 2=Critical, 3=Error, 4=Warning, 5=Notice, 6=Info, 7=Debug

# Info message (Facility=16 local0, Severity=6 info) = 16*8+6 = 134
send_syslog 134 "custom-app[$$]" "This is an INFO message from custom app"
echo "Sent: INFO message"
sleep 1

# Warning message (Facility=16 local0, Severity=4 warning) = 16*8+4 = 132
send_syslog 132 "custom-app[$$]" "This is a WARNING: Disk space running low"
echo "Sent: WARNING message"
sleep 1

# Error message (Facility=16 local0, Severity=3 error) = 16*8+3 = 131
send_syslog 131 "custom-app[$$]" "This is an ERROR: Connection failed"
echo "Sent: ERROR message"
sleep 1

# Critical message (Facility=16 local0, Severity=2 critical) = 16*8+2 = 130
send_syslog 130 "custom-app[$$]" "This is a CRITICAL: System overheating"
echo "Sent: CRITICAL message"
sleep 1

echo ""
echo "2. Sending structured data..."
echo ""

# Send message with structured data (RFC 5424 format)
STRUCTURED_MSG='<134>1 2025-01-20T17:30:00.000Z myhost.example.com myapp 12345 ID47 [exampleSDID@32473 iut="3" eventSource="Application" eventID="1011"] Application started successfully'
echo "$STRUCTURED_MSG" | nc -u -w1 localhost 5515
echo "Sent: Structured data message"
sleep 1

echo ""
echo "3. Sending messages from different applications..."
echo ""

# Simulate different applications
send_syslog 134 "web-server[$$]" "HTTP request received: GET /api/users"
echo "Sent: web-server message"
sleep 1

send_syslog 134 "database[$$]" "Query executed: SELECT * FROM users"
echo "Sent: database message"
sleep 1

send_syslog 132 "backup-service[$$]" "Backup completed: 150MB archived"
echo "Sent: backup-service message"
sleep 1

echo ""
echo "4. Sending JSON formatted log..."
echo ""

# JSON log entry
JSON_LOG='{"timestamp":"2025-01-20T17:30:00Z","level":"info","service":"api-gateway","message":"Request processed","duration_ms":45,"status_code":200}'
send_syslog 134 "json-logger[$$]" "$JSON_LOG"
echo "Sent: JSON formatted message"

echo ""
echo "=== All messages sent! ==="
echo ""
echo "Check the logs with:"
echo "  - make logs-receiver"
echo "  - ls -la receiver/logs/remote/"
echo "  - tail -f receiver/logs/remote/*/custom-app.log"
