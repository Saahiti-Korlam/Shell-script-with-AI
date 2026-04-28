#!/bin/bash
#####################
# Description: This script creates and deletes a VPC in AWS using the AWS CLI.
# The script must accept parameters for creating a VPC and a public subnet, and it should # also verify if the AWS CLI is installed and configured correctly. 
# Finally, it should clean up by deleting the created VPC and subnet.
# For creation, script should accept create argument.
# For deletion, it should accept delete argument.
# It takes the following parameters:
# - Create VPC
# - Create a public Subnet
#
# - Verify if AWS is installed, User might use mac , linux or windows
# - verify if AWS CLI is configured correctly
#
# - Delete VPC
# - Delete Subnet
# usage:
# - ./aws_vpc_create.sh create
# - ./aws_vpc_create.sh create
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
if ! aws sts get-caller-identity --region $REGION &> /dev/null
then
    echo "AWS CLI is not configured correctly"
    exit 1
fi

# CREATE
if [ "$1" == "create" ]; then

    # Create VPC
    VPC_ID=$(aws ec2 create-vpc \
        --cidr-block $VPC_CIDR \
        --region $REGION \
        --query 'Vpc.VpcId' \
        --output text)

    # Tag VPC
    aws ec2 create-tags \
        --resources $VPC_ID \
        --tags Key=Name,Value=$VPC_NAME \
        --region $REGION

    # Create Subnet
    SUBNET_ID=$(aws ec2 create-subnet \
        --vpc-id $VPC_ID \
        --cidr-block $SUBNET_CIDR \
        --availability-zone $SUBNET_AVAILABILITY_ZONE \
        --region $REGION \
        --query 'Subnet.SubnetId' \
        --output text)

    # Make subnet public
    aws ec2 modify-subnet-attribute \
        --subnet-id $SUBNET_ID \
        --map-public-ip-on-launch \
        --region $REGION

    # Tag Subnet
    aws ec2 create-tags \
        --resources $SUBNET_ID \
        --tags Key=Name,Value=$SUBNET_NAME \
        --region $REGION

    echo "VPC $VPC_NAME ($VPC_ID) and Subnet $SUBNET_NAME ($SUBNET_ID) created successfully."

# DELETE
elif [ "$1" == "delete" ]; then

    echo "Fetching resources by Name tag..."

    # Get VPC ID by tag
    VPC_ID=$(aws ec2 describe-vpcs \
        --filters "Name=tag:Name,Values=$VPC_NAME" \
        --region $REGION \
        --query 'Vpcs[0].VpcId' \
        --output text)

    # Get Subnet ID by tag
    SUBNET_ID=$(aws ec2 describe-subnets \
        --filters "Name=tag:Name,Values=$SUBNET_NAME" \
        --region $REGION \
        --query 'Subnets[0].SubnetId' \
        --output text)

    # Validate
    if [ "$VPC_ID" == "None" ] || [ -z "$VPC_ID" ]; then
        echo "VPC not found"
        exit 1
    fi

    if [ "$SUBNET_ID" == "None" ] || [ -z "$SUBNET_ID" ]; then
        echo "Subnet not found"
        exit 1
    fi

    # Delete Subnet
    aws ec2 delete-subnet \
        --subnet-id $SUBNET_ID \
        --region $REGION

    # Delete VPC
    aws ec2 delete-vpc \
        --vpc-id $VPC_ID \
        --region $REGION

    echo "VPC $VPC_ID and Subnet $SUBNET_ID deleted successfully."

else
    echo "Usage: $0 {create|delete}"
    exit 1
fi

# End of script
