# Docker to Podman Migration Summary

This document summarizes all the changes made to migrate this project from Docker to Podman.

## Files Modified

### 1. **podman-compose.yml** (new file)
- Created as a copy of docker-compose.yml
- No changes needed to the compose file format as podman-compose supports the same syntax

### 2. **Makefile**
- Replaced all `docker-compose` commands with `podman-compose`
- Replaced all `docker` commands with `podman`
- Updated help text to mention "Podman" instead of "Docker"

### 3. **test_syslog.sh**
- Renamed `check_docker()` function to `check_podman()`
- Updated all `docker-compose` commands to `podman-compose`
- Updated error messages to reference Podman instead of Docker

### 4. **verify_syslog.sh**
- Updated `docker-compose ps` to `podman-compose ps`

### 5. **README.md**
- Changed title from "Docker Experiment" to "Podman Experiment"
- Updated all command examples to use `podman-compose`
- Updated troubleshooting section to mention Podman and podman-compose

### 6. **IMPROVEMENTS.md**
- Updated references to docker-compose.yml to podman-compose.yml

### 7. **.gitignore**
- Changed "Docker volumes" comment to "Podman volumes"

### 8. **docker-compose.yml**
- Removed (replaced by podman-compose.yml)

## Files NOT Modified

The following files did not require any changes as they don't contain Docker-specific references:

- **server/Dockerfile** - Podman uses the same Dockerfile format
- **receiver/Dockerfile** - Podman uses the same Dockerfile format
- **server/syslog-ng.conf**
- **receiver/rsyslog.conf**
- **server/syslog_test.c**
- **server/start.sh**
- **examples/send_custom_logs.sh**

## Usage After Migration

The usage remains exactly the same, just with Podman commands:

```bash
# Build and start containers
make build
make up

# View logs
make logs

# Stop containers
make down

# Run tests
./test_syslog.sh
./verify_syslog.sh
```

## Requirements

To use this project with Podman, you need:

1. **Podman** installed on your system
2. **podman-compose** installed (can be installed via pip: `pip install podman-compose`)

## Benefits of Podman

- Daemonless architecture (no background service required)
- Rootless containers by default (better security)
- Compatible with Docker images and Dockerfiles
- Same command-line interface as Docker
- Better systemd integration

## Compatibility Notes

- The compose file format remains the same
- All Docker images used in this project work with Podman
- Network and volume management work similarly
- Health checks function as expected

## Important: Port Configuration Change

Due to Podman's rootless mode restrictions, the following port change was necessary:

- **Original Docker setup**: Used port 514 (privileged port)
- **Podman setup**: Uses port 5515 (non-privileged port)

This change affects:
- `podman-compose.yml` - Port mapping changed from `514:514` to `5515:514`
- `test_syslog.sh` - Updated to send messages to port 5515
- `verify_syslog.sh` - Updated to send messages to port 5515
- `examples/send_custom_logs.sh` - Updated to use port 5515
- `README.md` - Added port configuration section

The internal container-to-container communication still uses port 514. Only the external host-to-container port mapping has changed.

The migration is complete and the project now uses Podman exclusively with port 5515 for external access.
