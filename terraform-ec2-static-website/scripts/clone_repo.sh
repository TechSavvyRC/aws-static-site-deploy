#!/bin/bash

# Enhanced deployment script for TechSavvyRC webapp
# This script handles secure API key injection and web server setup

set -euo pipefail  # Exit on error, undefined vars, and pipe failures

# Configuration variables - THESE ARE TERRAFORM VARIABLES (DO NOT ESCAPE)
GITHUB_REPO="${github_repo}"
SSM_PARAMETER_NAME="${ssm_parameter_name}"
AWS_REGION="${aws_region}"
CONTACT_EMAIL="${contact_email_id}"
CONTACT_NAME="${contact_name}"

# Derived variables - THESE ARE SHELL VARIABLES (MUST ESCAPE)
WEB_ROOT="/var/www/html"
PHP_CONFIG_FILE="$${WEB_ROOT}/forms/contact.php"
LOG_FILE="/var/log/deployment.log"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$${LOG_FILE}"
}

# Error handling function
error_exit() {
    log "ERROR: $1"
    exit 1
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

log "Starting deployment process..."

# 1. System update and package installation
log "Updating system and installing packages..."
dnf update -y || error_exit "Failed to update system"

# Install required packages with error handling
PACKAGES=(
    "nginx"
    "git"
    "php-fpm"
    "php-cli"
    "php-json"
    "php-curl"
    "php-mbstring"
    "php-xml"
    "php-zip"
    "aws-cli"
    "unzip"
)

for package in "$${PACKAGES[@]}"; do
    if ! dnf install -y "$${package}"; then
        error_exit "Failed to install $${package}"
    fi
done

log "All packages installed successfully"

# 2. Configure web root directory with proper permissions
log "Setting up web root directory..."
mkdir -p "$${WEB_ROOT}" || error_exit "Failed to create web root directory"
mkdir -p "$(dirname "$${LOG_FILE}")" || error_exit "Failed to create log directory"

# Set proper ownership and permissions
chown -R nginx:nginx /var/www || error_exit "Failed to set nginx ownership"
chmod -R 755 /var/www || error_exit "Failed to set directory permissions"

# 3. Deploy website from GitHub
log "Deploying website from GitHub..."
if [ -d "$${WEB_ROOT}/.git" ]; then
    log "Repository exists, pulling latest changes..."
    cd "$${WEB_ROOT}" || error_exit "Failed to change to web root directory"
    git pull origin main || error_exit "Failed to pull latest changes"
else
    log "Cloning repository for the first time..."
    git clone "$${GITHUB_REPO}" "$${WEB_ROOT}" || error_exit "Failed to clone repository"
fi

# Ensure proper permissions after git operations
chown -R nginx:nginx "$${WEB_ROOT}" || error_exit "Failed to set ownership after git operations"

# 4. Retrieve API key from SSM Parameter Store
log "Retrieving API key from SSM Parameter Store..."
if ! command_exists aws; then
    error_exit "AWS CLI is not installed"
fi

# Get the API key with proper error handling
API_KEY=$(aws ssm get-parameter \
    --name "$${SSM_PARAMETER_NAME}" \
    --with-decryption \
    --region "$${AWS_REGION}" \
    --query "Parameter.Value" \
    --output text 2>/dev/null) || error_exit "Failed to retrieve API key from SSM"

# Validate API key is not empty
if [ -z "$${API_KEY}" ] || [ "$${API_KEY}" = "None" ]; then
    error_exit "Retrieved API key is empty or invalid"
fi

log "API key retrieved successfully"

# 5. Inject API key into PHP configuration
log "Injecting API key into PHP configuration..."
if [ ! -f "$${PHP_CONFIG_FILE}" ]; then
    error_exit "PHP configuration file not found at $${PHP_CONFIG_FILE}"
fi

# Create backup of original file
cp "$${PHP_CONFIG_FILE}" "$${PHP_CONFIG_FILE}.backup" || error_exit "Failed to create backup"

# Replace the placeholder with the actual API key
sed -i "s|<insert_api_key>|$${API_KEY}|g" "$${PHP_CONFIG_FILE}" || error_exit "Failed to inject API key"
sed -i "s|<insert_email_id>|$${CONTACT_EMAIL}|g" "$${PHP_CONFIG_FILE}" || error_exit "Failed to inject API key"
sed -i "s|<insert_name>|$${CONTACT_NAME}|g" "$${PHP_CONFIG_FILE}" || error_exit "Failed to inject API key"

# Verify the replacement was successful
if grep -q "<insert_api_key>" "$${PHP_CONFIG_FILE}"; then
    error_exit "API key injection failed - placeholder still exists"
fi

log "API key injected successfully"

# 6. Configure Nginx
log "Configuring Nginx..."
cat > /etc/nginx/conf.d/techsavvyrc-webapp.conf << 'NGINX_CONF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;

    root /var/www/html;
    index index.html index.php;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;

    # Static assets with caching
    location / {
        try_files $uri $uri/ =404;
        expires 1d;
        add_header Cache-Control "public, no-transform";
    }

    # PHP-FPM handler
    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass unix:/var/run/php-fpm/www.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
        
        # Security for PHP files
        fastcgi_hide_header X-Powered-By;
    }

    # Deny access to hidden files
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }

    # Deny access to backup files
    location ~ ~$ {
        deny all;
        access_log off;
        log_not_found off;
    }

    # Logging
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log warn;
}
NGINX_CONF

# Test Nginx configuration
nginx -t || error_exit "Nginx configuration test failed"

log "Nginx configured successfully"

# 7. Install Composer via direct PHAR download
log "Installing Composer PHAR..."

# Switch to a safe temp dir
cd /tmp || error_exit "Failed to cd to /tmp"

# Download the latest stable Composer PHAR
curl -sS https://getcomposer.org/composer-stable.phar -o composer.phar \
  || error_exit "Failed to download composer-stable.phar"

# Move and make executable
mv composer.phar /usr/local/bin/composer \
  || error_exit "Failed to move composer.phar to /usr/local/bin"

chmod +x /usr/local/bin/composer \
  || error_exit "Failed to make /usr/local/bin/composer executable"

# Verify installation
if ! composer --version | tee -a "$${LOG_FILE}"; then
  error_exit "Composer --version check failed"
fi

log "Composer installed successfully"

# 8. Install SendinBlue SDK
log "Installing SendinBlue SDK..."
FORMS_DIR="$${WEB_ROOT}/forms"

if [ ! -d "$${FORMS_DIR}" ]; then
    error_exit "Forms directory not found at $${FORMS_DIR}"
fi

# Set proper ownership for forms directory
chown -R ec2-user:ec2-user "$${FORMS_DIR}" || error_exit "Failed to set forms directory ownership"

# Install dependencies as ec2-user
cd "$${FORMS_DIR}" || error_exit "Failed to change to forms directory"
sudo -u ec2-user composer require sendinblue/api-v3-sdk:^8.0 || error_exit "Failed to install SendinBlue SDK"

# Verify autoload.php exists
if [ ! -f "$${FORMS_DIR}/vendor/autoload.php" ]; then
    error_exit "autoload.php not found after Composer installation"
fi

log "SendinBlue SDK installed successfully"

# 9. Configure and start services
log "Configuring and starting services..."

# Configure PHP-FPM
sed -i 's/;date.timezone =/date.timezone = Europe\/Stockholm/' /etc/php.ini || log "Warning: Failed to set PHP timezone"

# Enable and start PHP-FPM
systemctl enable php-fpm || error_exit "Failed to enable PHP-FPM"
systemctl start php-fpm || error_exit "Failed to start PHP-FPM"

# Wait for PHP-FPM to be ready
sleep 2

# Enable and start Nginx
systemctl enable nginx || error_exit "Failed to enable Nginx"
systemctl start nginx || error_exit "Failed to start Nginx"

# Wait for services to stabilize
sleep 3

# 10. Final service status check
log "Checking service status..."
if ! systemctl is-active --quiet php-fpm; then
    error_exit "PHP-FPM is not running"
fi

if ! systemctl is-active --quiet nginx; then
    error_exit "Nginx is not running"
fi

# 11. Final permissions and cleanup
log "Setting final permissions..."
chown -R nginx:nginx "$${WEB_ROOT}" || error_exit "Failed to set final web root permissions"
chmod -R 755 "$${WEB_ROOT}" || error_exit "Failed to set final directory permissions"

# Set specific permissions for forms directory
chown -R nginx:nginx "$${FORMS_DIR}" || error_exit "Failed to set forms directory permissions"
chmod -R 755 "$${FORMS_DIR}" || error_exit "Failed to set forms directory permissions"

# Clean up sensitive variables
unset API_KEY

log "Deployment completed successfully!"
log "Services status:"
systemctl status php-fpm --no-pager -l | head -5 | tee -a "$${LOG_FILE}"
systemctl status nginx --no-pager -l | head -5 | tee -a "$${LOG_FILE}"

# Test web server response
if curl -s -o /dev/null -w "%%{http_code}" http://localhost | grep -q "200"; then
    log "Web server is responding correctly"
else
    log "Warning: Web server may not be responding correctly"
fi

log "Deployment script finished"