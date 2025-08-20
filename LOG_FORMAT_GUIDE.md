# Understanding Log Formats in the Syslog Experiment

When you run `make logs`, you see output from two containers: **syslog-server** and **syslog-receiver**. Each line is prefixed with a container ID to show which container generated it.

## Container Identification

- **ec9a8b229cc3** = syslog-server container
- **f288128a9a66** = syslog-receiver container

## Log Format Types

### 1. RFC5424 Format (from syslog-server)
```
ec9a8b229cc3 <14>1 2025-08-21T08:30:17+00:00 syslog-server syslog_test 13  [meta sequenceId="47"] Syslog test program ending
```

**Breakdown:**
- `ec9a8b229cc3` - Container ID (syslog-server)
- `<14>` - Priority value (facility * 8 + severity)
  - Facility: 1 (user-level messages) 
  - Severity: 6 (informational)
  - Priority: 1 * 8 + 6 = 14
- `1` - RFC5424 version number
- `2025-08-21T08:30:17+00:00` - ISO8601 timestamp with timezone
- `syslog-server` - Hostname
- `syslog_test` - Application/program name
- `13` - Process ID (PID)
- `[meta sequenceId="47"]` - Structured data (key-value pairs)
- `Syslog test program ending` - The actual log message

### 2. Simple Format (from syslog-receiver)
```
f288128a9a66 Aug 21 08:30:17 syslog-server syslog_test[13] Syslog test program ending
```

**Breakdown:**
- `f288128a9a66` - Container ID (syslog-receiver)
- `Aug 21 08:30:17` - Traditional syslog timestamp
- `syslog-server` - Source hostname
- `syslog_test[13]` - Program name with PID in brackets
- `Syslog test program ending` - The actual log message

### 3. System Messages
```
ec9a8b229cc3 Starting syslog-ng...
ec9a8b229cc3 syslog-ng: Error setting capabilities, capability management disabled; error='Operation not permitted'
```

These are operational messages from the containers themselves, not syslog messages.

## Priority Values (PRI)

The priority value in `<PRI>` is calculated as: **facility × 8 + severity**

### Common Severities:
- 0 = Emergency
- 1 = Alert
- 2 = Critical
- 3 = Error (err)
- 4 = Warning
- 5 = Notice
- 6 = Informational (info)
- 7 = Debug

### Common Facilities:
- 0 = Kernel
- 1 = User-level
- 2 = Mail
- 3 = System daemons
- 16 = Local use 0 (local0)

### Examples from the logs:
- `<11>` = Priority 11 = Facility 1 (user) × 8 + Severity 3 (error) = Error message
- `<12>` = Priority 12 = Facility 1 (user) × 8 + Severity 4 (warning) = Warning message
- `<13>` = Priority 13 = Facility 1 (user) × 8 + Severity 5 (notice) = Notice message
- `<14>` = Priority 14 = Facility 1 (user) × 8 + Severity 6 (info) = Info message
- `<15>` = Priority 15 = Facility 1 (user) × 8 + Severity 7 (debug) = Debug message

## Data Flow

1. **syslog_test program** → generates log messages
2. **syslog-ng (server)** → receives logs, formats them as RFC5424, displays on console, forwards to receiver
3. **rsyslog (receiver)** → receives RFC5424 logs, parses them, reformats to simple format, displays on console

## Why Different Formats?

- **syslog-server** uses RFC5424 format because:
  - It's the modern standard (RFC 5424)
  - Supports structured data
  - Uses ISO8601 timestamps
  - More precise and machine-readable

- **syslog-receiver** shows simple format because:
  - rsyslog is configured to parse incoming RFC5424 and display in traditional format
  - Easier for humans to read
  - Compatible with older log processing tools

## Structured Data

The `[meta sequenceId="47"]` part is structured data, which RFC5424 supports. This allows adding metadata to log messages in a standardized way. In this case, syslog-ng is adding a sequence ID to track message order.

## Reading the Logs

When troubleshooting:
1. Look at the container ID prefix to know which service generated the line
2. For RFC5424 format, check the priority to understand severity
3. The timestamp shows when the event occurred
4. The hostname shows which container originated the message
5. The program name and PID help identify the specific process
6. The message contains the actual event information
