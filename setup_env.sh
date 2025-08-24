#!/bin/bash

# BARQ Environment Setup Script

set -e

echo "=== BARQ Environment Setup Started ==="
echo "Hostname: $(hostname)"
echo "Date: $(date)"

# 1. Create Application Logs Directory
echo ""
echo "Creating /var/log/barq/ directory."
mkdir -p /var/log/barq/
chmod 755 /var/log/barq/

# 2. Create log files with yesterday's and today's date
TODAY=$(date +"%Y-%m-%d")
YESTERDAY=$(date -d "yesterday" +"%Y-%m-%d")

echo "Creating log files for today ($TODAY) and yesterday ($YESTERDAY)."

# Create today's log files
touch "/var/log/barq/barq-${TODAY}.log"
touch "/var/log/barq/application-${TODAY}.log"
touch "/var/log/barq/barq.log"

# Create yesterday's log file 
touch "/var/log/barq/barq-${YESTERDAY}.log"
touch "/var/log/barq/application-${YESTERDAY}.log"


echo "[${YESTERDAY} 10:31:20] User authentication module loaded" > "/var/log/barq/application-${YESTERDAY}.log"
echo "[${YESTERDAY} 10:31:21] Cache system initialized" >> "/var/log/barq/application-${YESTERDAY}.log"


# Set proper permissions
chown -R root:root /var/log/barq/
chmod 644 /var/log/barq/*.log

# 3. Create TLS Certificate Directory
echo ""
echo "Creating /etc/ssl/patrol/ directory..."
mkdir -p /etc/ssl/patrol/
chmod 755 /etc/ssl/patrol/

# 4. Generate short-lived self-signed certificates for testing
echo "Generating self-signed certificates..."

# Certificate 1: barq-test.crt (30 days)
openssl req -x509 -newkey rsa:2048 -keyout /etc/ssl/patrol/barq-test.key \
    -out /etc/ssl/patrol/barq-test.crt -days 30 -nodes \
    -subj "/C=EG/ST=Cairo/L=Cairo/O=BARQ/OU=IT/CN=barq-test.local"

# Certificate 2: barq-api.crt (7 days - short for testing expiry)
openssl req -x509 -newkey rsa:2048 -keyout /etc/ssl/patrol/barq-api.key \
    -out /etc/ssl/patrol/barq-api.crt -days 7 -nodes \
    -subj "/C=EG/ST=Cairo/L=Cairo/O=BARQ/OU=API/CN=barq-api.local"

# Certificate 3: barq-web.crt (60 days)
openssl req -x509 -newkey rsa:2048 -keyout /etc/ssl/patrol/barq-web.key \
    -out /etc/ssl/patrol/barq-web.crt -days 60 -nodes \
    -subj "/C=EG/ST=Cairo/L=Cairo/O=BARQ/OU=WEB/CN=barq-web.local"

# Set proper permissions for certificates
chmod 600 /etc/ssl/patrol/*.key
chmod 644 /etc/ssl/patrol/*.crt

# 5. Create directories needed for future steps
echo ""
echo "Creating additional directories for BARQ application..."
mkdir -p /opt/barq/releases/
mkdir -p /opt/barq/
mkdir -p /var/reports/
mkdir -p /usr/local/bin/

chmod 755 /opt/barq/releases/
chmod 755 /opt/barq/
chmod 755 /var/reports/
chmod 755 /usr/local/bin/

# 6. Create a sample JAR file if not provided (for testing)
if [ ! -f "/opt/shared/barq-lite.jar" ]; then
    echo "Creating sample JAR file for testing..."
    mkdir -p /opt/shared/
    echo "Sample JAR content for testing" > /opt/shared/barq-lite.jar
fi

# 7. Start and enable cron service
echo ""
echo "Starting cron service..."
service cron start

# 8. Verification
echo ""
echo "=== Verification ==="
echo "Log directory contents:"
ls -la /var/log/barq/

echo ""
echo "Certificate directory contents:"
ls -la /etc/ssl/patrol/

echo ""
echo "Certificate expiry dates:"
for cert in /etc/ssl/patrol/*.crt; do
    if [ -f "$cert" ]; then
        echo "📄 $(basename "$cert"):"
        openssl x509 -in "$cert" -dates -noout | grep "notAfter"
    fi
done

echo ""
echo "Cron service status:"
service cron status
