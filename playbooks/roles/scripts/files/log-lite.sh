#!/bin/bash
# BARQ Log Compression & Retention Script

LOG_DIR="/var/log/barq"
YESTERDAY=$(date -d "yesterday" +%Y-%m-%d)
RETENTION_DAYS=7

echo "=== BARQ Log Management Started ==="
echo "Date: $(date)"
echo "Log Directory: $LOG_DIR"
echo "Yesterday: $YESTERDAY"
echo

# 1. Compress yesterday’s logs
echo "Compressing logs for $YESTERDAY..."
find "$LOG_DIR" -type f -name "*$YESTERDAY*.log" -exec gzip {} \;

# 2. Delete compressed logs older than 7 days
echo "Deleting compressed logs older than $RETENTION_DAYS days..."
find "$LOG_DIR" -type f -name "*.gz" -mtime +$RETENTION_DAYS -exec rm -f {} \;

echo "=== BARQ Log Management Completed ==="
