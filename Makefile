# Makefile for Syslog Experiment

.PHONY: help build up down logs test clean clean-all status restart

# Default target
help:
	@echo "Syslog Experiment - Available commands:"
	@echo "  make build    - Build Podman images"
	@echo "  make up       - Start containers"
	@echo "  make down     - Stop containers and remove volumes"
	@echo "  make restart  - Restart containers"
	@echo "  make logs     - Show logs from both containers"
	@echo "  make test     - Run the test script"
	@echo "  make status   - Show container status"
	@echo "  make clean    - Stop containers, remove volumes, and clean log files"
	@echo "  make clean-all - Deep clean: remove everything including networks"
	@echo "  make shell-server   - Open shell in server container"
	@echo "  make shell-receiver - Open shell in receiver container"

# Build Podman images
build:
	podman-compose build

# Start containers
up:
	podman-compose up -d
	@echo "Waiting for services to start..."
	@sleep 5
	@echo "Containers are running. Use 'make logs' to view output."

# Stop containers
down:
	podman-compose down -v
	@echo "Stopped containers and removed volumes"

# Restart containers
restart: down up

# Show logs
logs:
	podman-compose logs -f

# Run test script
test:
	./test_syslog.sh

# Show container status
status:
	podman-compose ps

# Clean up
clean:
	podman-compose down -v
	rm -rf server/logs/* receiver/logs/*
	@echo "Cleaned up containers, volumes, and log files"

# Open shell in server container
shell-server:
	podman exec -it syslog-server /bin/bash

# Open shell in receiver container
shell-receiver:
	podman exec -it syslog-receiver /bin/bash

# Specific log commands
logs-server:
	podman-compose logs -f syslog-server

logs-receiver:
	podman-compose logs -f syslog-receiver

# Deep clean - remove everything including networks
clean-all:
	podman-compose down -v --remove-orphans
	rm -rf server/logs/* receiver/logs/*
	# Remove any dangling volumes
	@podman volume prune -f 2>/dev/null || true
	# Remove the specific network if it exists
	@podman network rm syslog-experiment_default 2>/dev/null || true
	@echo "Deep clean completed: removed containers, volumes, networks, and log files"

# Check log files
check-files:
	@echo "=== Server Logs ==="
	@find server/logs -type f -name "*.log" 2>/dev/null || echo "No server log files found"
	@echo ""
	@echo "=== Receiver Logs ==="
	@find receiver/logs -type f -name "*.log" 2>/dev/null || echo "No receiver log files found"
