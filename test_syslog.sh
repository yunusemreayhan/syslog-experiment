#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Syslog Experiment Test Script ===${NC}"
echo ""

# Function to check if Podman is running
check_podman() {
    if ! podman info > /dev/null 2>&1; then
        echo -e "${RED}Error: Podman is not running or not installed${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Podman is running${NC}"
}

# Function to build and start containers
start_containers() {
    echo -e "\n${YELLOW}Building and starting containers...${NC}"
    podman-compose down > /dev/null 2>&1
    podman-compose up --build -d
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Containers started successfully${NC}"
    else
        echo -e "${RED}✗ Failed to start containers${NC}"
        exit 1
    fi
}

# Function to wait for services to be ready
wait_for_services() {
    echo -e "\n${YELLOW}Waiting for services to be ready...${NC}"
    
    # Wait for receiver to be healthy
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if podman-compose ps | grep -q "syslog-receiver.*healthy"; then
            echo -e "${GREEN}✓ Receiver is healthy${NC}"
            break
        fi
        attempt=$((attempt + 1))
        sleep 1
    done
    
    if [ $attempt -eq $max_attempts ]; then
        echo -e "${RED}✗ Receiver failed to become healthy${NC}"
        exit 1
    fi
    
    # Give server a moment to start
    sleep 3
}

# Function to check logs
check_logs() {
    echo -e "\n${YELLOW}Checking log generation...${NC}"
    
    # Check server logs
    echo -e "\n${GREEN}Server logs:${NC}"
    podman-compose logs --tail=10 syslog-server
    
    # Check receiver logs
    echo -e "\n${GREEN}Receiver logs:${NC}"
    podman-compose logs --tail=10 syslog-receiver
    
    # Check log files
    echo -e "\n${GREEN}Log files created:${NC}"
    
    # Server logs
    if [ -d "server/logs" ] && [ "$(ls -A server/logs)" ]; then
        echo -e "${GREEN}✓ Server log directory:${NC}"
        find server/logs -type f -name "*.log" | head -5
    else
        echo -e "${YELLOW}⚠ No server log files found yet${NC}"
    fi
    
    # Receiver logs
    if [ -d "receiver/logs/remote" ] && [ "$(ls -A receiver/logs/remote)" ]; then
        echo -e "${GREEN}✓ Receiver log directory:${NC}"
        find receiver/logs/remote -type f -name "*.log" | head -5
    else
        echo -e "${YELLOW}⚠ No receiver log files found yet${NC}"
    fi
}

# Function to send test message
send_test_message() {
    echo -e "\n${YELLOW}Sending test message via logger...${NC}"
    
    # Send a test message using logger to the receiver
    echo "test message from host" | nc -u -w1 localhost 5515
    
    echo -e "${GREEN}✓ Test message sent${NC}"
}

# Function to show monitoring commands
show_monitoring() {
    echo -e "\n${GREEN}=== Monitoring Commands ===${NC}"
    echo "To monitor logs in real-time, use:"
    echo -e "${YELLOW}podman-compose logs -f syslog-server${NC}    # Server logs"
    echo -e "${YELLOW}podman-compose logs -f syslog-receiver${NC}  # Receiver logs"
    echo -e "${YELLOW}podman-compose logs -f${NC}                  # All logs"
    echo ""
    echo "To check log files:"
    echo -e "${YELLOW}ls -la receiver/logs/remote/syslog-server/${NC}"
    echo -e "${YELLOW}tail -f receiver/logs/remote/syslog-server/syslog_test.log${NC}"
}

# Function to stop containers
stop_containers() {
    echo -e "\n${YELLOW}Stopping containers...${NC}"
    podman-compose down
    echo -e "${GREEN}✓ Containers stopped${NC}"
}

# Main execution
main() {
    case "${1:-}" in
        start)
            check_podman
            start_containers
            wait_for_services
            echo -e "\n${GREEN}Syslog experiment is running!${NC}"
            show_monitoring
            ;;
        stop)
            stop_containers
            ;;
        test)
            send_test_message
            ;;
        logs)
            check_logs
            ;;
        status)
            podman-compose ps
            ;;
        *)
            check_podman
            start_containers
            wait_for_services
            
            echo -e "\n${YELLOW}Waiting for initial logs...${NC}"
            sleep 10
            
            check_logs
            show_monitoring
            
            echo -e "\n${GREEN}=== Test Complete ===${NC}"
            echo "The syslog experiment is running. The C program will send 20 messages."
            echo "Use './test_syslog.sh stop' to stop the containers when done."
            ;;
    esac
}

# Run main function
main "$@"
