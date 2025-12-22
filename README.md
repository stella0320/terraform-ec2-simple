# terraform-ec2-simple
terraform practice

<img width="711" height="431" alt="雲端架構圖" src="https://github.com/user-attachments/assets/11fea561-cbe8-4193-acab-62fe764a1716" />

## Features

- Creates AWS VPC with public subnet
- Deploys EC2 instance with SSH access
- Automatic public IP assignment
- Discord notifications for deployment status (optional)

## Discord Notifications

This project supports sending deployment information to Discord via webhooks.

### Setup Discord Webhook

1. Open your Discord server
2. Go to Server Settings → Integrations → Webhooks
3. Click "New Webhook"
4. Name your webhook (e.g., "Terraform Deployments")
5. Select the channel where notifications should be sent
6. Copy the webhook URL

### Enable Discord Notifications

#### Method 1: Using Terraform Variables

1. Copy the example configuration:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` and add your webhook URL:
   ```hcl
   enable_discord_notifications = true
   discord_webhook_url = "https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN"
   ```

3. Run Terraform:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

#### Method 2: Using the Standalone Script

You can also send notifications manually using the provided script:

```bash
./send_discord_notification.sh <webhook_url> <ec2_ip> [instance_type] [vpc_cidr] [region]
```

Example:
```bash
./send_discord_notification.sh \
  "https://discord.com/api/webhooks/..." \
  "54.123.45.67" \
  "t2.nano" \
  "10.0.0.0/18" \
  "ap-northeast-1"
```

### Notification Content

The Discord notification includes:
- 🖥️ EC2 Public IP address
- 📦 Instance type
- 🌍 AWS region
- 🌐 VPC CIDR block
- 🔑 Ready-to-use SSH command

## Usage

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Plan the deployment:
   ```bash
   terraform plan
   ```

3. Apply the configuration:
   ```bash
   terraform apply
   ```

4. SSH into your instance:
   ```bash
   ssh ubuntu@<ec2_public_ip>
   ```

## Security Notes

- The `discord_webhook_url` variable is marked as sensitive
- Never commit your `terraform.tfvars` file to version control
- Add `terraform.tfvars` to your `.gitignore`

## Requirements

- Terraform >= 0.12
- AWS credentials configured
- `curl` command (for Discord notifications)
