# TechSavvyRC WebApp Deployment Guide

## 📘 Overview
This guide walks you through deploying a static personal website on AWS using Terraform and Nginx. It includes everything from setting up your environment to using a custom domain with SSL via Cloudflare. Suitable for anyone looking to host a static website securely and professionally.

---

## 🧰 Prerequisites

### 1. Terraform Installed
- Follow the guide to install Terraform CLI:  
  👉 https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

### 2. Code Editor (Recommended: Visual Studio Code)
- Download VS Code:  
  👉 https://code.visualstudio.com/download
- Get started with VS Code:  
  👉 https://code.visualstudio.com/docs/getstarted/getting-started

### 3. AWS Account & IAM User
- Ensure you have an existing AWS account.
- Create a separate IAM user (not the root user) with programmatic access.
- Use this IAM user for AWS CLI setup and Terraform deployments.

---

## 💻 AWS CLI (Windows)

### ✅ Supported Requirements
- 64-bit Windows (Microsoft-supported versions)
- Admin rights required to install software

### 🔧 Install or Update AWS CLI
- Download the MSI Installer:  
  👉 https://awscli.amazonaws.com/AWSCLIV2.msi

- Or use the following command in CMD:
```bash
C:\> msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi
```
- For silent install (no prompts):
```bash
C:\> msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi /qn
```

### 🛠️ Configure AWS CLI
```bash
C:\> aws configure
AWS Access Key ID [None]: XXXXXXXXXXXXXXXX
AWS Secret Access Key [None]: XXXXXXXXXXXXXXXXXXXXXXXXXXX
Default region name [None]: eu-north-1
Default output format [None]: json
```

### 🧪 Verify Installation
```bash
C:\> aws --version
```
Example output:
```
aws-cli/2.19.1 Python/3.11.6 Windows/10 exe/AMD64 prompt/off
```
> 💡 If `aws` is not found, restart CMD or follow [AWS CLI Troubleshooting](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-troubleshooting.html).

To verify CLI can communicate with your AWS account:
```bash
aws iam get-user
```
Example output:
```json
{
    "User": {
        "Path": "/",
        "UserName": "user01",
        "UserId": "xxxxxxxxxx",
        "Arn": "arn:aws:iam::xxxxxxxx6:user/user01",
        "CreateDate": "2025-07-09T12:47:15+00:00",
        "PasswordLastUsed": "2025-07-09T13:11:25+00:00",
        "Tags": [
            {
                "Key": "AXXXXXXXXXXXXXXXXXXXX",
                "Value": "Terraform User"
            }
        ]
    }
}
```

---

## 🌱 Project Structure
```
TechSavvyRC/aws-static-site-deploy
│
├── terraform-ec2-static-website
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   └── userdata.sh
│
└── README.md
```

---

## 🛠️ Deployment Workflow

### 🔨 Step 1: Prepare Website Source Code
- Design or download a free HTML/CSS website template
- Customize content
- Upload all static files (HTML, CSS, JS) to a public GitHub repository

### 🌐 Step 2: Configure Local Environment
- Install Terraform, AWS CLI, and Visual Studio Code
- Configure AWS credentials using IAM user via `aws configure`

### ☁️ Step 3: Define Terraform Infrastructure
Terraform will:
- Provision an EC2 instance (Amazon Linux 2023)
- Install Nginx and Git using `userdata.sh`
- Pull website code from GitHub and place it under `/var/www/html`
- Start the Nginx service to serve your site

👉 Sample Terraform code is available in this GitHub repository: `<link to your GitHub repository>`  
> You can clone and reuse this code after updating necessary variables and configurations.

### 🚀 Step 4: Deploy Infrastructure
```bash
git clone https://github.com/your/repo.git
cd aws-static-website
terraform init
terraform plan
terraform apply
```

### 🔐 Step 5: Access the Server
```bash
ssh -i your-key.pem ec2-user@<your-ec2-public-ip>
```

### 🌍 Step 6: Visit Your Website
Open in browser:
```
http://<your-ec2-public-ip>
```

---

## 🌐 Domain & SSL (Optional but Recommended)

### 1. Buy a Domain Name
- Use providers like **Hostinger**, **GoDaddy**, or **Namecheap**

### 2. Move DNS to Cloudflare
- Sign up for [Cloudflare](https://www.cloudflare.com)
- Add your domain
- Update nameservers in your domain registrar (e.g., Hostinger)

### 3. Add DNS Records
- Add an **A Record** in Cloudflare DNS pointing to your EC2 Public IP

### 4. Enable SSL & HTTPS
- Go to SSL/TLS settings in Cloudflare
- Enable **Always Use HTTPS** and **Automatic HTTPS Rewrites**
- Your site will now be available securely at:
```
https://yourdomain.com
```
> 🔐 Free SSL via Cloudflare ensures your site is trusted with a padlock icon

---

## 🧹 Teardown Resources
```bash
terraform destroy
```
> ⚠️ This will delete your EC2 instance and all provisioned infrastructure.

---

## 🛡️ Best Practices & Notes
- Keep `terraform.tfstate` and AWS credentials secure
- Never commit `.pem` key or sensitive data to GitHub
- Limit IAM user permissions to only what's necessary
- Regularly destroy unused resources to avoid charges
- Use custom domains with SSL to enhance professionalism and security

---

## 🚨 ATTENTION

### ⚠️ Free SSL and Public IP Caution
Using free SSL certificates (such as Cloudflare) with public EC2 IP exposure is acceptable for **personal** or **portfolio** sites. **Not recommended for production or sensitive workloads.**

### 💳 Monitor AWS Billing Regularly
Even if using Free Tier EC2, monitor your [AWS Billing Dashboard](https://console.aws.amazon.com/billing/home) to avoid unexpected charges.

### 🧼 Manual Cleanup
After testing or if no longer needed, **run `terraform destroy`** to remove all AWS resources and prevent ongoing costs.

### 🔐 IAM & Key Security
Use a **dedicated IAM user**, avoid root credentials, and **do not share or expose PEM keys** in public repositories.

### 🌍 Domain Visibility
Once DNS is set up and propagated, **your public IP is visible** through DNS lookups. If privacy is a concern, consider alternatives such as Cloudflare proxy or private hosting.

---

## 📬 Need Help?
Open an issue or reach out on GitHub.

---

## 🖼️ Architecture Diagram
![Architecture Diagram](https://dummyimage.com/800x400/cccccc/000000&text=GitHub+%E2%86%92+Terraform+%E2%86%92+AWS+EC2+%2B+Cloudflare+DNS+%2B+SSL+%3D+Live+Website)
> Diagram: GitHub (Source) → Terraform (Infra) → EC2 (Web Server) → Cloudflare (DNS+SSL) → End Users
