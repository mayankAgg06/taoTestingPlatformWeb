# TAO Testing Platform - Complete Deployment Guide

## Overview

This guide provides step-by-step instructions for your organization's deployment team to spin up the TAO Assessment Platform on AWS with custom credentials.

---

## Prerequisites

Before starting, ensure your AWS EC2 instance has:

- **OS:** Ubuntu 20.04 LTS or later
- **RAM:** Minimum 4GB (8GB recommended)
- **Storage:** Minimum 20GB (50GB recommended)
- **Ports Open:** 80 (HTTP), 443 (HTTPS), 3306 (MySQL - internal only)
- **Docker & Docker Compose:** Pre-installed

---

## Step 1: Launch AWS EC2 Instance

### 1.1 Create EC2 Instance

1. Go to AWS Console → EC2 → Launch Instance
2. Select **Ubuntu 20.04 LTS** AMI (or latest LTS)
3. Choose instance type: **t3.medium** (minimum) or **t3.large** (recommended)
4. Configure storage: **50GB** (gp3 or gp2)
5. Configure security group:
   - Allow port **80** (HTTP) from anywhere
   - Allow port **443** (HTTPS) from anywhere
   - Allow port **22** (SSH) from your office IP
6. Create/Select key pair and download it
7. Launch instance

### 1.2 Get Instance IP

Note your instance's **Public IPv4 address** (e.g., `54.123.45.67`)

---

## Step 2: SSH into Instance

```bash
ssh -i /path/to/your-key.pem ubuntu@your-instance-ip
```

Example:
```bash
ssh -i ~/Downloads/tao-deployment.pem ubuntu@54.123.45.67
```

---

## Step 3: Install Docker (If Not Pre-installed)

```bash
# Update package manager
sudo apt update

# Install Docker
sudo apt install -y docker.io docker-compose

# Add ubuntu user to docker group
sudo usermod -aG docker ubuntu

# Verify installation
docker --version
docker-compose --version
```

---

## Step 4: Clone Repository

```bash
cd /home/ubuntu

git clone https://github.com/mayankAgg06/taoTestingPlatformWeb.git

cd taoTestingPlatformWeb

ls -la
```

You should see:
```
.gitignore
Dockerfile
README.md
deploy.sh
docker-compose-dev.yml
logo_white.svg
nginx.conf
```

---

## Step 5: Customize Credentials (IMPORTANT)

### 5.1 Update docker-compose-dev.yml

Edit the file to change default credentials:

```bash
nano docker-compose-dev.yml
```

**Find these lines under the `database` service:**

```yaml
environment:
  MYSQL_ROOT_PASSWORD: r00t          # Change this
  MYSQL_USER: tao                     # Change this (optional)
  MYSQL_PASSWORD: tao                 # Change this
  MYSQL_DATABASE: tao                 # Change this (optional)
```

**Change to your organization's credentials:**

Example:
```yaml
environment:
  MYSQL_ROOT_PASSWORD: Sharda@SecurePassword123    # Your secure password
  MYSQL_USER: sharda_tao                           # Your username
  MYSQL_PASSWORD: Sharda@TaoPass456                # Your secure password
  MYSQL_DATABASE: tao_sharda                       # Your database name
```

**Also update the `tao` service environment variables:**

```yaml
environment:
  DOCKER_COMPOSE_WAIT_HOSTS: "database:3306"
  DB_HOST: "database"
  DB_PORT: "3306"
  DB_NAME: "tao_sharda"              # Match MYSQL_DATABASE above
  DB_USER: "sharda_tao"              # Match MYSQL_USER above
  DB_PASSWORD: "Sharda@TaoPass456"   # Match MYSQL_PASSWORD above
```

**Save the file:** Press `Ctrl+X`, then `Y`, then `Enter`

---

## Step 6: Start the Application

```bash
cd /home/ubuntu/taoTestingPlatformWeb

docker-compose -f docker-compose-dev.yml up -d
```

Wait 3-5 minutes for containers to start and initialize.

---

## Step 7: Verify Containers Are Running

```bash
docker ps
```

You should see 3 containers running:
- `example-database-1` (MySQL)
- `example-tao-1` (TAO PHP-FPM)
- `example-web-1` (Nginx)

Check logs:
```bash
docker logs example-tao-1 --tail 20
```

Look for message: `TAO platform was successfully installed`

---

## Step 8: Configure MySQL User Permissions

```bash
docker exec -it example-database-1 mysql -u root -pYourRootPassword -e "ALTER USER 'sharda_tao'@'%' IDENTIFIED WITH mysql_native_password BY 'Sharda@TaoPass456'; FLUSH PRIVILEGES;"
```

Replace:
- `YourRootPassword` with your root password from Step 5
- `sharda_tao` with your username
- `Sharda@TaoPass456` with your password

---

## Step 9: Access TAO Web Installer

Open your browser and go to:

```
http://your-instance-public-ip/tao/install
```

Example: `http://54.123.45.67/tao/install`

---

## Step 10: Complete TAO Installation

Fill in the installation wizard with:

### Database Configuration

| Field | Value |
|-------|-------|
| Database Driver | `pdo_mysql` |
| Host | `database` |
| Database Name | `tao_sharda` (or your DB name from Step 5) |
| Database User | `sharda_tao` (or your username from Step 5) |
| Database Password | `Sharda@TaoPass456` (or your password from Step 5) |

### Administrator Account

| Field | Value |
|-------|-------|
| Admin Username | `admin` (or your choice) |
| Admin Password | Create a **strong, unique password** |
| Confirm Password | Repeat the password |

### Installation Mode

- **Development:** For testing and development
- **Production:** For live system (recommended for production AWS)

### Sample Data

- **Yes:** To load sample tests and questions
- **No:** For clean installation

---

## Step 11: Complete Installation & Login

Click through the wizard. Once installation completes:

1. Go to `http://your-instance-public-ip`
2. Login with your admin credentials from Step 10
3. Verify the Sharda University logo appears

---

## Step 12: Enable HTTPS (Recommended for Production)

### Option A: Use AWS Certificate Manager (Recommended)

1. Go to AWS Certificate Manager
2. Request a public certificate for your domain
3. Create an Application Load Balancer (ALB) in front of your EC2
4. Attach the certificate to the ALB
5. Forward traffic to your EC2 instance on port 80

### Option B: Use Let's Encrypt (Free)

```bash
cd /home/ubuntu/taoTestingPlatformWeb

# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Get certificate (requires domain name)
sudo certbot certonly --standalone -d your-domain.com

# Update nginx.conf to use SSL
# This requires manual configuration
```

---

## Important: Backup Your Credentials

**Save this information securely:**

```
Organization: Sharda University
Application: TAO Testing Platform
Instance IP: [Your IP]
Database User: sharda_tao
Database Password: [Your Password]
Admin Username: admin
Admin Password: [Your Password]
Backup Location: [Where you store backups]
```

Store in:
- ✅ Password manager (1Password, LastPass, Vault)
- ✅ Secure document (encrypted)
- ❌ Plaintext files
- ❌ Email

---

## Step 13: Daily Operations

### Check Container Status

```bash
docker ps
```

### View Application Logs

```bash
docker logs example-tao-1
docker logs example-web-1
docker logs example-database-1
```

### Restart Application

```bash
cd /home/ubuntu/taoTestingPlatformWeb
docker-compose -f docker-compose-dev.yml restart
```

### Stop Application

```bash
docker-compose -f docker-compose-dev.yml down
```

### Start Application

```bash
docker-compose -f docker-compose-dev.yml up -d
```

---

## Step 14: Backup Your Data

### Backup Database

```bash
docker exec example-database-1 mysqldump -u sharda_tao -pYourPassword tao_sharda > /home/ubuntu/tao_backup_$(date +%Y%m%d_%H%M%S).sql
```

Replace:
- `sharda_tao` with your username
- `YourPassword` with your password
- `tao_sharda` with your database name

### Backup to S3 (Recommended)

```bash
# Install AWS CLI
sudo apt install -y awscli

# Configure AWS credentials
aws configure

# Backup to S3
docker exec example-database-1 mysqldump -u sharda_tao -pYourPassword tao_sharda | aws s3 cp - s3://your-backup-bucket/tao-backup-$(date +%Y%m%d).sql
```

---

## Troubleshooting

### Issue: 502 Bad Gateway

**Solution:**
```bash
# Wait for TAO to fully start
docker logs example-tao-1

# If not ready, restart
docker-compose -f docker-compose-dev.yml restart example-tao-1

# Wait 2-3 minutes and refresh browser
```

### Issue: Database Connection Error

**Solution:**
```bash
# Verify database is running
docker ps | grep database

# Check database logs
docker logs example-database-1

# Verify credentials match
nano docker-compose-dev.yml
```

### Issue: Port 80 Already in Use

**Solution:**
```bash
# Find what's using port 80
sudo lsof -i :80

# Kill the process
sudo kill -9 <PID>

# Restart containers
docker-compose -f docker-compose-dev.yml restart
```

### Issue: Container Won't Start

**Solution:**
```bash
# Check logs
docker logs example-tao-1

# Rebuild containers
docker-compose -f docker-compose-dev.yml down
docker volume prune -f
docker-compose -f docker-compose-dev.yml up -d
```

---

## Support & Maintenance

### Monthly Tasks

- ✅ Test backups to ensure they work
- ✅ Review application logs
- ✅ Check disk space usage
- ✅ Update OS packages: `sudo apt update && sudo apt upgrade`

### Security

- ✅ Keep EC2 instance updated
- ✅ Use strong passwords
- ✅ Enable AWS CloudTrail for audit logging
- ✅ Restrict SSH access by IP
- ✅ Regularly backup database

---

## Contact & Questions

For issues or questions about TAO:
- Documentation: https://taotesting.com/documentation
- GitHub: https://github.com/oat-sa
- Community: https://github.com/oat-sa/tao-core/discussions

---

**Installation Complete!** 🎉

Your TAO Testing Platform is now ready for production use.
