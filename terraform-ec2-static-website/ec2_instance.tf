############################################################
# File: ec2_instance.tf
#
# Description:
# Defines the main EC2 instance used to host the Static
# static website using NGINX on Amazon Linux 2023.
#
# Purpose:
# - Provisions an EC2 instance with appropriate configuration.
# - Installs and configures NGINX with custom headers and caching.
# - Automatically clones the static website from GitHub repo.
#
# Contribution to Overall Setup:
# This is the compute resource running the production website.
# Bootstrap is handled via `user_data`, ensuring zero manual steps.
#
# Best Practices:
# - Uses variables for flexibility.
# - Includes tags for easier identification.
# - Automates full provisioning using `user_data`.
# - NGINX config is declared inline within EC2 instance creation.
############################################################

# Define the EC2 instance resource
resource "aws_instance" "web" {
  # Use the specified AMI (Amazon Linux 2023)
  ami = var.ami_id

  # EC2 instance type, default is t3.micro (Free Tier eligible)
  instance_type = var.instance_type

  # Associate the EC2 Key Pair created by Terraform
  key_name = aws_key_pair.deployer.key_name
  #key_name = "<your_existing_key_name>"

  # Attach security group that allows SSH, HTTP, and HTTPS
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  #vpc_security_group_ids = ["sg-0ee5f6f626e80c130"]

  # Inline user_data script to fully bootstrap the EC2 instance
  user_data = <<-EOF
    #!/bin/bash

    # 1. System update and install packages
    dnf update -y
    dnf install -y nginx git

    # 2. Configure web root directory
    mkdir -p /var/www/html
    chown -R nginx:nginx /var/www
    chmod -R 755 /var/www

    # 3. Deploy website from GitHub (clone if first time, pull otherwise)
    if ! git clone ${var.github_repo} /var/www/html; then
      cd /var/www/html && git pull origin main
    fi

    # 4. Write custom NGINX configuration with security and performance settings
    cat > /etc/nginx/conf.d/<your_ngnix_file_name>.conf << 'NGINX_CONF'
    server {
        listen 80;
        server_name _;

        root /var/www/html;
        index index.html;

        # Security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header Referrer-Policy "strict-origin-when-cross-origin" always;
        add_header Permissions-Policy "geolocation=(),midi=(),sync-xhr=(),microphone=(),camera=(),magnetometer=(),gyroscope=(),fullscreen=(self),payment=()" always;

        # Compression
        gzip on;
        gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
        gzip_min_length 1024;
        gzip_proxied any;
        gzip_comp_level 5;
        gzip_vary on;

        # Static file caching
        location ~* \.(?:css|js|jpe?g|png|gif|ico|svg|woff2?)$ {
            expires 30d;
            add_header Cache-Control "public, no-transform";
            access_log off;
            log_not_found off;
        }

        location / {
            try_files $uri $uri/ =404;
            add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data:;" always;
        }

        # Security settings
        server_tokens off;
        client_max_body_size 1m;
        client_body_buffer_size 16k;
        client_header_buffer_size 1k;

        # Logging
        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log warn;
    }
    NGINX_CONF

    # 5. Validate and start NGINX
    nginx -t && systemctl enable nginx && systemctl restart nginx
  EOF

  # Resource tagging for identification and filtering
  tags = {
    Name = var.ec2_instance_name
  }
}
