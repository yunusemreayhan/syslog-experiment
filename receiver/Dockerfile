FROM debian:bullseye-slim

# Install rsyslog and dumb-init for proper signal handling
RUN apt-get update && apt-get install -y \
    rsyslog \
    dumb-init \
    && rm -rf /var/lib/apt/lists/*

# Copy rsyslog configuration
COPY rsyslog.conf /etc/rsyslog.conf

# Copy startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Create log directories
RUN mkdir -p /var/log/remote

# Expose syslog ports
EXPOSE 514/udp
EXPOSE 514/tcp

# Use dumb-init to ensure proper signal handling
ENTRYPOINT ["dumb-init", "--"]

# Start rsyslog using the startup script
CMD ["/start.sh"]
