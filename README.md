# BARQ Lite – Two-Server Operations Project

BARQ Lite is a lightweight Java application deployed across two Linux servers. This project demonstrates full environment setup, log management, TLS certificate reporting, and automated application deployment using **Bash** and **Ansible**, with optional Docker support.

---

## Project Overview

The project is organized into several phases:

### 1. Environment Setup

Before deploying the application, the environment must be initialized on both servers. You can automate this using the provided `setup_env.sh` script.

**What the script does ? :**

1. **Application Logs**
   - Creates the directory `/var/log/barq/`.
   - Generates at least two log files:
     - One with yesterday's date.
     - One with today's date.

2. **Java Application Release**
   - Places the prebuilt `barq-lite.jar` in the appropriate location.
   - Ensures the app can run with:
     ```bash
     java -jar barq-lite.jar
     ```
   - When started, the app writes logs to `/var/log/barq/barq.log`.

3. **TLS Certificate Folder**
   - Creates `/etc/ssl/patrol/`.
   - Generates at least one short-lived self-signed certificate for testing.

**Run the script:**
```bash
sudo bash setup_env.sh
```

### 2. Log Compression & Retention

Bash script `log-lite.sh` compresses yesterday's logs and deletes logs older than 7 days.
Scheduled via cron to run daily at 01:10.

### 3. Java Application Deployment

Ansible tasks:
- Upload the JAR to `/opt/barq/releases/<release_id>/`.
- Update the `/opt/barq/current` symlink.
- Deploy a systemd service `barq.service` to run the app at boot.
- Application logs are written to `/var/log/barq/barq.log`.

### 4. TLS Certificate Report

Bash script `cert-lite.sh` scans `/etc/ssl/patrol/*.crt` and generates `/var/reports/cert-lite.txt` containing:
`cert_name | NotAfter_date | days_remaining`.
Scheduled via cron at 07:00 daily.

### 5. Optional Docker Deployment

Docker image for `barq-lite.jar` based on `openjdk:17-jdk`.
Can run the app as a container exposing port 8080.

## Logs

All application-related logs are maintained under `/var/log/barq/`:
- **Current application log**: `/var/log/barq/barq.log`
- **Daily logs**: `barq-YYYY-MM-DD.log` and `application-YYYY-MM-DD.log`
- **Compressed logs**: `*.gz` for logs older than one day

The logs track both application activity and environment setup events, providing a complete audit trail.

## How to Run the Playbooks

1. Ensure Ansible is installed on your control machine.
2. Update the `inventory.ini` file with your server IPs and SSH credentials.
3. Execute the playbook:
   ```bash
   ansible-playbook -i inventory.ini playbooks/site.yml
   ```

## Assumptions

- Both servers have Java 17 installed.
- Cron service is running on the servers.
- User has sudo privileges to create directories and deploy services.
- Docker is installed if using the optional container deployment.

## Package Dependencies

- Java 17 JDK
- Bash
- Ansible (control machine)
- Docker & Docker Compose (optional)
- Cron (for scheduled scripts)
