FROM debian:bullseye-slim

# Install syslog-ng, build tools, and dumb-init for proper signal handling
RUN apt-get update && apt-get install -y \
    syslog-ng \
    syslog-ng-core \
    syslog-ng-mod-sql \
    gcc \
    make \
    libc6-dev \
    dumb-init \
    && rm -rf /var/lib/apt/lists/*

# Copy syslog-ng configuration
COPY syslog-ng.conf /etc/syslog-ng/syslog-ng.conf

# Copy and compile the C program
COPY syslog_test.c /usr/src/syslog_test.c
RUN gcc -o /usr/local/bin/syslog_test /usr/src/syslog_test.c

# Create log directory
RUN mkdir -p /var/log

# Create a startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Expose syslog ports
EXPOSE 514/udp
EXPOSE 514/tcp

# Use dumb-init to ensure proper signal handling
ENTRYPOINT ["dumb-init", "--"]

# Start syslog-ng and the test program
CMD ["/start.sh"]
