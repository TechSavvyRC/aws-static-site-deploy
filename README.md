
# 🚀 Static Website Deployment with Contact Form & Secure Email Integration

*A Step-by-Step Guide Using AWS EC2, Custom Domain, and Secure Secrets Injection*

---

## 🔧 Prerequisites

Before proceeding, ensure you have:

* ✅ A **domain name** (e.g., `yourdomain.com`)
* ✅ A **GitHub repo** containing your static website with a contact form (e.g., HTML + PHP)
* ✅ An **email provider** offering SMTP or API-based transactional email services
  (*Examples*: [Sendinblue](https://www.brevo.com), [Mailgun](https://www.mailgun.com), [Postmark](https://postmarkapp.com))
* ✅ An **email address** from your domain (e.g., `contact@yourdomain.com`) via providers like:

  * [Zoho Mail](https://zoho.com/mail)
  * [Google Workspace](https://workspace.google.com/)
  * [ProtonMail](https://proton.me)
* ✅ An **AWS Free Tier account**
* ✅ [Terraform](https://www.terraform.io/downloads) installed locally
* ✅ AWS CLI configured (`aws configure`) with access to deploy EC2, IAM, and SSM

---

## 🌐 Step 1: Set Up Your Domain and Email

1. **Transfer or manage your domain** in Cloudflare or your DNS provider.
2. **Set up your domain email** using a provider (e.g., Zoho Mail, ProtonMail).
3. Add the required **MX, SPF, DKIM, and DMARC** records via DNS to allow verified sending.
4. If using a transactional email provider:

   * Create a sender identity (Example: `contactme@yourdomain.com`)
   * Generate your **SMTP/API key**
   * Enable domain authentication (SPF/DKIM) on your provider dashboard

---

## 🔒 Step 2: Store the API Key in AWS Parameter Store

1. Open the **AWS Systems Manager Console**
2. Go to **Parameter Store → Create parameter**
3. Fill out:

```
Name: /webapp/api_key                # Example path
Description: API key for transactional email
Tier: Standard
Type: SecureString
KMS Key: Default (alias/aws/ssm)
Value: <YOUR_API_KEY>               # e.g., xkeysib-abc123...
```

> 💡 Use a hierarchical name (`/webapp/api_key`) to organize keys

---

## 🏗 Step 3: Prepare Your GitHub Repository

1. Clone a static website template (HTML, CSS, PHP)
2. Create a `contact.php` file with the form handler logic
3. Inside `contact.php`, include this placeholder:

```php
$config = Configuration::getDefaultConfiguration()->setApiKey(
  'api-key',
  '<INSERT_API_KEY>' // Will be replaced via Terraform
);
```

You can view a complete working example of the `contact.php` script [here](https://github.com/TechSavvyRC/techsavvyrc-webapp/blob/main/forms/contact.php).

4. Push your code to GitHub (e.g., `https://github.com/yourusername/your-repo`)

---

## 💻 Step 4: Terraform Project Structure

Your project should contain:

```
TechSavvyRC/aws-static-site-deploy
│
└── terraform-ec2-static-website
    │
    ├── scripts/
    │    └ clone_repo.sh
    │
    ├── providers.tf
    ├── variables.tf
    ├── security_group.tf
    ├── ec2_roles.tf
    ├── keypair.tf
    ├── ec2_instance.tf
    └── outputs.tf
```

Terraform will:
- Provision an EC2 instance (Amazon Linux 2023 Free Tier)
- Assign an IAM role to allow secure access to AWS Parameter Store
- Run a user_data script that:
  - Installs Nginx, PHP, PHP-FPM, Composer, and required PHP extensions
  - Clones your static website from a GitHub repository into /var/www/html
  - Replaces the <insert_api_key>, <insert_email_id> and <insert_name> placeholder in contact.php using a value securely fetched from Parameter Store
  - Installs the Brevo (Sendinblue) SDK via Composer inside /var/www/html/forms
  - Configures and starts Nginx and PHP-FPM to serve your site and handle contact form submissionste

👉 Sample Terraform code is available in this GitHub repository: `https://github.com/TechSavvyRC/aws-static-site-deploy.git`  
> You can clone and reuse this code after updating necessary variables and configurations.

---

## ☁️ Step 5: Deploy with Terraform

```bash
git clone https://github.com/TechSavvyRC/aws-static-site-deploy.git
cd aws-static-website
terraform init
terraform plan
terraform apply
```

---

## 🌐 Step 6: Configure DNS and SSL (Optional)

1. In **Cloudflare** or your DNS provider, create an **A record**:

   ```
   Type: A
   Name: @
   Value: <EC2_PUBLIC_IP>
   TTL: Auto
   ```
2. Enable **“Full” SSL/TLS encryption**
3. Optionally, enable **Auto HTTPS Rewrites** and **Always Use HTTPS**

---

## 🛠 Step 7: Test and Debug

* Visit `http://<your_domain>` in a browser
* Submit the contact form
* If no email is received:

  * Check **browser console** for JavaScript errors
  * Check `/var/log/nginx/error.log` on EC2
  * Check `/tmp/email_error.log` for Sendinblue/API errors
  * Ensure `autoload.php` is present:

    ```
    ls -l /var/www/html/forms/vendor/autoload.php
    ```

---

## ✅ Summary

You now have a fully working, production-ready deployment that:

* Hosts a static website using NGINX
* Sends secure form data to a backend PHP script
* Uses a transactional email provider via API key
* Injects secrets securely at runtime using AWS SSM
* Enables HTTPS via Cloudflare (optional)

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

