#!/bin/bash

INSTANCE_ID=$1

EC2_INFO=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --output text \
    --query "Reservations[0].Instances[0].[InstanceId,InstanceType,State.Name,LaunchTime,VpcId,SubnetId,PrivateIpAddress,PublicIpAddress]")

read ID TYPE STATE LAUNCH VPC SUBNET PRIVATE PUBLIC <<< "$EC2_INFO"

echo "=== EC2 Information ==="
echo "Instance ID   : $ID"
echo "Instance Type : $TYPE"
echo "State         : $STATE"
echo "Launch Time   : $LAUNCH"
echo "VPC ID        : $VPC"
echo "Subnet ID     : $SUBNET"
echo "Private IP    : $PRIVATE"
echo "Public IP     : ${PUBLIC:-N/A}"