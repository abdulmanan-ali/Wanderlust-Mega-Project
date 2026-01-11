#!/bin/bash
set -e

INSTANCE_ID="i-03f807dfe45640a84"
REGION="us-east-1"   # <-- USE YOUR REAL REGION

echo "===== DEBUG INFO ====="
echo "Running as user: $(whoami)"
echo "Instance ID: $INSTANCE_ID"
echo "Region: $REGION"
echo "======================"

ipv4_address=$(aws ec2 describe-instances \
  --region "$REGION" \
  --instance-ids "$INSTANCE_ID" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

echo "Resolved IP: $ipv4_address"

# Path to the .env file
file_to_find="../backend/.env.docker"

# Check the current FRONTEND_URL in the .env file
current_url=$(sed -n "4p" $file_to_find)

# Update the .env file if the IP address has changed
if [[ "$current_url" != "FRONTEND_URL=\"http://${ipv4_address}:5173\"" ]]; then
    if [ -f $file_to_find ]; then
        sed -i -e "s|FRONTEND_URL.*|FRONTEND_URL=\"http://${ipv4_address}:5173\"|g" $file_to_find
    else
        echo "ERROR: File not found."
    fi
fi
