#!/bin/bash

REPORT_DIR="/var/reports"
REPORT_FILE="$REPORT_DIR/cert-lite.txt"
CERT_DIR="/etc/ssl/patrol"

mkdir -p "$REPORT_DIR"

echo "cert_name | NotAfter_date | days_remaining | status" > "$REPORT_FILE"

for cert in "$CERT_DIR"/*.crt; do
    if [[ -f "$cert" ]]; then
        cert_name=$(basename "$cert")
        not_after=$(openssl x509 -enddate -noout -in "$cert" | cut -d= -f2)
        end_date=$(date -d "$not_after" +%s)
        today=$(date +%s)
        days_remaining=$(( (end_date - today) / 86400 ))

        if [[ $days_remaining -le 0 ]]; then
            status="EXPIRED"
        elif [[ $days_remaining -le 30 ]]; then
            status="Expiring Soon"
        else
            status="Valid"
        fi

        echo "$cert_name | $not_after | $days_remaining | $status" >> "$REPORT_FILE"
    fi
done
