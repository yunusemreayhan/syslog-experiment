# Syslog-ng and Rsyslog Podman Experiment

This project demonstrates a syslog setup using Podman containers:
- **Server**: Uses syslog-ng with a C binary that generates syslog messages
- **Receiver**: Uses rsyslog to receive and store logs from the server

## Architecture

```
┌─────────────────────┐         ┌──────────────────────┐
│   syslog-server     │         │   syslog-receiver    │
│                     │         │                      │
│  - syslog-ng        │  UDP    │  - rsyslog           │
│  - C test program   │ ──────> │  - Receives logs     │
│  - Generates logs   │  :514   │  - Stores by host    │
└─────────────────────┘         └──────────────────────┘
```

## Components

### Server Container
- **Base**: Debian Bullseye
- **Syslog daemon**: syslog-ng
- **Test program**: C binary using syslog() function
- **Configuration**: Custom syslog-ng.conf that forwards logs to receiver

### Receiver Container
- **Base**: Debian Bullseye
- **Syslog daemon**: rsyslog
- **Configuration**: Custom rsyslog.conf that receives and categorizes logs

### C Test Program
The server includes a C program (`syslog_test.c`) that:
- Uses the standard syslog() function
- Generates various log levels (INFO, WARNING, ERROR, DEBUG, NOTICE)
- Sends 20 test messages with 5-second intervals
- Demonstrates proper syslog API usage

## Usage

### Quick Start with Make

The project includes a Makefile for easy management:

```bash
# Show available commands
make help

# Build and start containers
make build
make up

# View logs
make logs

# Run the test script
make test

# Stop containers
make down

# Clean up everything
make clean
```

### Manual Podman Commands

1. **Start the containers:**
   ```bash
   podman-compose up --build
   ```

2. **Watch the logs:**
   - Server logs will appear in the console
   - Receiver logs will also be displayed
   - Log files are stored in:
     - `./server/logs/` - Server-side logs
     - `./receiver/logs/` - Received logs organized by hostname

3. **Stop the experiment:**
   ```bash
   podman-compose down
   ```

### Testing and Verification

The project includes two helper scripts:

1. **test_syslog.sh** - Comprehensive testing script
   ```bash
   ./test_syslog.sh        # Full test with container startup
   ./test_syslog.sh start  # Just start containers
   ./test_syslog.sh stop   # Stop containers
   ./test_syslog.sh logs   # Check logs
   ./test_syslog.sh test   # Send test message
   ```

2. **verify_syslog.sh** - Quick verification of syslog functionality
   ```bash
   ./verify_syslog.sh      # Verify syslog is working correctly
   ```

## Configuration Files

### syslog-ng.conf (Server)
- Listens on local system sources
- Forwards logs from the test program to the receiver
- Logs to console for monitoring
- Creates separate log file for test program

### rsyslog.conf (Receiver)
- Listens on UDP/TCP port 514
- Organizes logs by hostname and program name
- Categorizes logs by severity level
- Outputs to console for real-time monitoring

## Log Flow

1. C program calls `syslog()` → Local syslog socket
2. syslog-ng receives the message
3. syslog-ng forwards to receiver via UDP
4. rsyslog receives and stores the message
5. Logs are organized in `/var/log/remote/<hostname>/<program>.log`

## Monitoring

You can monitor the logs in real-time:

```bash
# View server logs
podman-compose logs -f syslog-server

# View receiver logs
podman-compose logs -f syslog-receiver

# Check log files
ls -la ./receiver/logs/remote/
```

## Examples

The `examples/` directory contains additional scripts:

- **send_custom_logs.sh** - Demonstrates how to send custom syslog messages
  ```bash
  ./examples/send_custom_logs.sh
  ```
  This script shows:
  - Sending messages with different severity levels
  - Using structured data format (RFC 5424)
  - Simulating logs from different applications
  - Sending JSON-formatted logs

## Customization

- Modify `syslog_test.c` to change log generation behavior
- Edit `syslog-ng.conf` to adjust forwarding rules
- Update `rsyslog.conf` to change log organization
- Add more containers to test multi-host scenarios
- Use the examples as templates for your own logging needs

## Troubleshooting

- Ensure Podman and podman-compose are installed
- Check that port 5515 (TCP/UDP) is not in use (Podman rootless mode cannot bind to privileged port 514)
- Verify network connectivity between containers
- Look for error messages in container logs

## Port Configuration

Due to Podman's rootless mode restrictions, the syslog receiver is exposed on port **5515** instead of the standard 514. All scripts and examples have been updated to use this port. The internal container-to-container communication still uses port 514.
