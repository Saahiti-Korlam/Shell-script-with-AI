# AWS VPC Automation using Shell Script (AI-Assisted) 
> **Note:** This shell script was designed with the help of GitHub Copilot and AI pair programming.

---
## 📋 Overview

This project automates the creation and deletion of AWS VPC infrastructure using the AWS CLI and a Bash shell script. The script was iteratively developed — starting from a basic VPC creation script, then enhanced to support command-line arguments for both **create** and **delete** operations.

---

## ✅ Prerequisites

| Requirement | Details |
|---|---|
| AWS CLI | Must be installed (supports macOS, Linux, Windows) |
| AWS Credentials | Must be configured via `aws configure` |
| IAM Permissions | EC2 full access or at minimum VPC/Subnet permissions |
| Shell | Bash |

---


## 🏗️ Infrastructure Details

| Parameter | Value |
|---|---|
| VPC CIDR | `10.0.0.0/16` |
| Subnet CIDR | `10.0.4.0/24` |
| Region | `ap-south-1` |
| Availability Zone | `ap-south-1b` |
| VPC Name | `My-custom-VPC1` |
| Subnet Name | `My-custom-Subnet1` |


---

## 🚀 Implementation Steps

### Phase 1 — Basic VPC Creation Script

1. Created a Bash script `aws_create_vpc.sh` with hardcoded variables for VPC CIDR, Subnet CIDR, region, and availability zone.
2. Added a **pre-flight check** to verify if the AWS CLI is installed on the system.
3. Added a **configuration check** using `aws sts get-caller-identity` to confirm valid AWS credentials.
4. Implemented VPC creation using `aws ec2 create-vpc` and captured the returned `VpcId`.
5. Tagged the VPC with a human-readable name using `aws ec2 create-tags`.
6. Created a public subnet inside the VPC using `aws ec2 create-subnet` with a specific availability zone.
7. Tagged the subnet similarly with a name tag.
8. Granted execute permissions to the script and ran it successfully.

```bash
chmod 777 aws_create_vpc.sh
./aws_create_vpc.sh
```

**Result:** VPC and Subnet were created successfully with name tags applied.
<img width="734" height="76" alt="script-create-op" src="https://github.com/user-attachments/assets/3f945986-f5e8-42d7-8fe3-15fd57356dbd" />
<img width="959" height="68" alt="script-op" src="https://github.com/user-attachments/assets/e559872e-93ff-4162-855f-42f4919dcfc3" />
 ## AWS Console - VPC
 <img width="957" height="342" alt="vpc-aws-console" src="https://github.com/user-attachments/assets/8dcbf89b-8113-4354-9f3d-bcb442b3731a" />


---

### Phase 2 — Enhanced Script with Create & Delete Arguments

The script was refactored to accept runtime command-line arguments (`create` / `delete`), making it reusable and production-friendly.

1. Added argument parsing logic using `$1` to differentiate between `create` and `delete` modes.
2. **Create mode:**
   - Creates the VPC and tags it.
   - Creates the subnet inside the VPC and tags it.
   - Enables **auto-assign public IP** on the subnet using `modify-subnet-attribute`.
3. **Delete mode:**
   - Looks up the VPC and Subnet by their **Name tags** (no hardcoded IDs needed).
   - Validates that both resources exist before attempting deletion.
   - Deletes the subnet first, then the VPC (order matters in AWS).
4. Added a fallback `else` block to display usage instructions if an invalid argument is passed.

```bash
./aws_vpc_create.sh create   # Provision VPC + Subnet
./aws_vpc_create.sh delete   # Tear down VPC + Subnet
```

**Result:** VPC and Subnets are created or deleted cleanly based on the argument passed.

<img width="512" height="55" alt="deletion-op" src="https://github.com/user-attachments/assets/52f4f66c-c537-42f6-85d0-1de007879a11" />
<img width="859" height="205" alt="subnet-deleted" src="https://github.com/user-attachments/assets/ef60ea75-7ba1-4ce7-9113-a9d0ffc41b18" />

<img width="950" height="292" alt="vpc-deleted" src="https://github.com/user-attachments/assets/03a130b9-dcde-4cbe-9a1f-d523b433aae2" />


---

## 🧠 Key Concepts Applied

- **Idempotent tag-based lookups** — delete mode finds resources by Name tag rather than hardcoded IDs, making the script portable across runs.
- **AWS CLI query filtering** — used `--query` and `--filters` to extract specific fields from AWS API responses.
- **Public subnet configuration** — `--map-public-ip-on-launch` ensures instances launched in the subnet receive a public IP automatically.
- **Pre-flight validations** — both AWS CLI installation and credential configuration are verified before any AWS API calls are made.

---

## 📌 Summary

A Bash automation script was developed with AI assistance to manage AWS VPC infrastructure lifecycle. The script evolved from a simple creation utility into a fully argument-driven tool supporting both **provisioning** and **teardown** of a VPC and its associated public subnet in the `ap-south-1` region. The script includes robust pre-checks, resource tagging, and tag-based resource discovery for clean deletion — making it suitable for repeated use in dev/test environments.





