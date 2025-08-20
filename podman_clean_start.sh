#!/bin/bash

# Clean start script for Podman - working around stuck containers

echo "=== Podman Clean Start Script ==="
echo ""

# Check for any running containers
echo "Checking for existing containers..."
podman ps -a

# Try to clean up if possible
echo ""
echo "Attempting cleanup..."
podman-compose down 2>/dev/null || true
podman rm -f $(podman ps -aq) 2>/dev/null || true

# Create a new podman-compose file with different ports and names
cat > podman-compose-fresh.yml << 'EOF'
version: '3.8'

services:
  syslog_receiver:
    build: ./receiver
    container_name: syslog_receiver_fresh
    hostname: syslog-receiver-fresh
    networks:
      - syslog_network
    ports:
      - "5516:514/udp"
      - "5516:514/tcp"
    volumes:
      - ./receiver/logs:/var/log
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "pidof", "rsyslogd"]
      interval: 10s
      timeout: 5s
      retries: 3

  syslog_server:
    build: ./server
    container_name: syslog_server_fresh
    hostname: syslog-server-fresh
    networks:
      - syslog_network
    volumes:
      - ./server/logs:/var/log
    depends_on:
      syslog_receiver:
        condition: service_healthy
    restart: unless-stopped
    environment:
      - SYSLOG_RECEIVER=syslog-receiver-fresh

networks:
  syslog_network:
    driver: bridge
    name: syslog_net_fresh
EOF

echo ""
echo "Created new compose file: podman-compose-fresh.yml"
echo "Using port 5516 instead of 5514/5515"
echo ""

# Build images with new tags
echo "Building images..."
podman build -t syslog-receiver-fresh:latest ./receiver
podman build -t syslog-server-fresh:latest ./server

# Start containers
echo ""
echo "Starting containers with new configuration..."
podman-compose -f podman-compose-fresh.yml up -d

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Containers started successfully!"
    echo ""
    echo "Waiting for services to be ready..."
    sleep 5
    
    echo ""
    echo "Container status:"
    podman-compose -f podman-compose-fresh.yml ps
    
    echo ""
    echo "Commands:"
    echo "  Check status:  podman-compose -f podman-compose-fresh.yml ps"
    echo "  View logs:     podman-compose -f podman-compose-fresh.yml logs -f"
    echo "  Test syslog:   echo 'Test message' | nc -u localhost 5516"
    echo "  Stop:          podman-compose -f podman-compose-fresh.yml down"
else
    echo "✗ Failed to start containers"
    echo ""
    echo "Troubleshooting:"
    echo "1. Check if port 5516 is available: sudo netstat -tulpn | grep 5516"
    echo "2. Check podman status: podman info"
    echo "3. Try restarting podman: systemctl --user restart podman"
    exit 1
fi
