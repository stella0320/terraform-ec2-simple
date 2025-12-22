#!/bin/bash

# Discord Notification Script for AWS EC2 Deployment
# Usage: ./send_discord_notification.sh <webhook_url> <ec2_ip> <instance_type> <vpc_cidr>

set -e

WEBHOOK_URL="$1"
EC2_IP="$2"
INSTANCE_TYPE="${3:-t2.nano}"
VPC_CIDR="${4:-10.0.0.0/18}"
REGION="${5:-ap-northeast-1}"

if [ -z "$WEBHOOK_URL" ] || [ -z "$EC2_IP" ]; then
    echo "Usage: $0 <webhook_url> <ec2_ip> [instance_type] [vpc_cidr] [region]"
    echo "Example: $0 https://discord.com/api/webhooks/... 54.123.45.67"
    exit 1
fi

TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%S.000Z)

# Create JSON payload
JSON_PAYLOAD=$(cat <<EOF
{
  "embeds": [
    {
      "title": "🚀 AWS Infrastructure Deployed",
      "description": "Your Terraform deployment has completed successfully!",
      "color": 3066993,
      "fields": [
        {
          "name": "🖥️ EC2 Public IP",
          "value": "\`${EC2_IP}\`",
          "inline": true
        },
        {
          "name": "📦 Instance Type",
          "value": "\`${INSTANCE_TYPE}\`",
          "inline": true
        },
        {
          "name": "🌍 Region",
          "value": "\`${REGION}\`",
          "inline": true
        },
        {
          "name": "🌐 VPC CIDR",
          "value": "\`${VPC_CIDR}\`",
          "inline": true
        },
        {
          "name": "🔑 SSH Command",
          "value": "\`\`\`bash\nssh ubuntu@${EC2_IP}\`\`\`",
          "inline": false
        }
      ],
      "timestamp": "${TIMESTAMP}",
      "footer": {
        "text": "Terraform EC2 Deployment"
      }
    }
  ]
}
EOF
)

# Send notification to Discord
curl -H "Content-Type: application/json" \
     -d "$JSON_PAYLOAD" \
     "$WEBHOOK_URL"

echo ""
echo "✅ Discord notification sent successfully!"
