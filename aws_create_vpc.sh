	#!/bin/bash
#####################
# This script creates a VPC in AWS using the AWS CLI.
# It takes the following parameters:
# - Create VPC
# - Create a public Subnet
#
# - Verify if AWS is installed, User might use mac , linux or windows
# - verify if AWS CLI is configured correctly
##################

# Variables
VPC_CIDR="10.0.0.0/16"
SUBNET_CIDR="10.0.4.0/24"
REGION="ap-south-1"
VPC_NAME="My-custom-VPC1"
SUBNET_NAME="My-custom-Subnet1"
SUBNET_AVAILABILITY_ZONE="ap-south-1b"

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null
then
    echo "AWS CLI is not installed"
    exit 1
fi

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null
then
    echo "AWS CLI is not configured correctly"
    exit 1
fi
# Create VPC
VPC_ID=$(aws ec2 create-vpc --cidr-block $VPC_CIDR --query 'Vpc.VpcId' --output text)

# Add name tag to the VPC
aws ec2 create-tags --resources $VPC_ID --tags Key=Name,Value=$VPC_NAME

#Create Subnet
SUBNET_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $SUBNET_CIDR --availability-zone $SUBNET_AVAILABILITY_ZONE --query 'Subnet.SubnetId' --output text)

# Add name tag to the Subnet
aws ec2 create-tags --resources $SUBNET_ID --tags Key=Name,Value=$SUBNET_NAME

echo "VPC $VPC_NAME with ID $VPC_ID and Subnet $SUBNET_NAME with ID $SUBNET_ID created successfully in region $REGION."

# End of script
