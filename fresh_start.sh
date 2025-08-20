#!/bin/bash

# Fresh start script for Podman migration

echo "=== Fresh Start for Podman Syslog Experiment ==="
echo ""

# Create a new podman-compose file with unique names
cat > podman-compose-new.yml << 'EOF'
version: '3.8'

services:
  receiver:
    build: ./receiver
    container_name: syslog-recv
    hostname: syslog-receiver
    networks:
      - syslognet
    ports:
      - "5515:514/udp"
      - "5515:514/tcp"
    volumes:
      - ./receiver/logs:/var/log
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "pidof", "rsyslogd"]
      interval: 10s
      timeout: 5s
      retries: 3

  server:
    build: ./server
    container_name: syslog-srv
    hostname: syslog-server
    networks:
      - syslognet
    volumes:
      - ./server/logs:/var/log
    depends_on:
      receiver:
        condition: service_healthy
    restart: unless-stopped
    environment:
      - SYSLOG_RECEIVER=syslog-receiver

networks:
  syslognet:
    driver: bridge
EOF

echo "Created new compose file with unique container names"
echo ""

# Start containers
echo "Starting containers..."
podman-compose -f podman-compose-new.yml up -d

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Containers started successfully!"
    echo ""
    echo "To check status: podman-compose -f podman-compose-new.yml ps"
    echo "To view logs: podman-compose -f podman-compose-new.yml logs -f"
    echo "To stop: podman-compose -f podman-compose-new.yml down"
else
    echo "✗ Failed to start containers"
    exit 1
fi
