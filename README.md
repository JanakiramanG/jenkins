# Jenkins on AWS — Hybrid Cloud Terraform (Modular)

## Architecture

```
Internet / On-Prem
        │
        ▼
Route53  A-alias
jenkins.<domain>
        │
        ▼
┌───────────────────────────────┐
│  NLB  (internet-facing)       │
│  Public Subnets               │
│  Listener: TCP  443           │
│  Target type: ALB             │
└──────────────┬────────────────┘
               │ TCP 443
               ▼
┌───────────────────────────────┐
│  ALB  (internal)              │
│  Private Subnets              │
│  Listener: HTTPS 443          │
│  ACM Certificate (DNS-valid.) │
│  Target Group: EC2 :8080      │
└──────────────┬────────────────┘
               │ HTTP 8080
               ▼
┌───────────────────────────────┐
│  EC2  (private subnet)        │
│  Jenkins installed via        │
│  userdata (Amazon Linux 2023) │
│  IMDSv2 enforced              │
│  SSM + CloudWatch agent       │
└───────────────────────────────┘
```

## Module Structure

```
jenkins/
├── main.tf                        # Root — calls all modules
├── variables.tf                   # Root input variables
├── outputs.tf                     # Root outputs
├── versions.tf                    # Provider & Terraform version constraints
├── terraform.tfvars.example       # Example variable values
└── modules/
    ├── vpc/                       # VPC, subnets, IGW, NAT GW, route tables
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── security_groups/           # SGs for NLB, ALB, EC2
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── acm/                       # ACM cert + Route53 DNS validation
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── ec2/                       # Jenkins EC2, IAM role, userdata
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── userdata/
    │       └── jenkins_install.sh
    ├── alb/                       # Internal ALB, HTTPS listener, target group
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── nlb/                       # Internet-facing NLB, TCP 443, ALB target
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── route53/                   # A alias record → NLB
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Prerequisites

- Terraform >= 1.5
- AWS credentials configured (`aws configure` or env vars)
- A Route53 **public** hosted zone for your domain
- An EC2 key pair (optional — SSM Session Manager works without one)

## Quick Start

```bash
# 1. Clone
git clone https://github.com/JanakiramanG/jenkins.git
cd jenkins

# 2. Configure
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars — set domain_name, hosted_zone_id, key_name

# 3. Deploy
terraform init
terraform plan
terraform apply
```

After apply completes, open:
```
https://jenkins.<your-domain>
```

Retrieve the initial admin password via SSM (no bastion needed):
```bash
aws ssm start-session --target <ec2-instance-id>
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

## Variables

| Variable               | Description                                          | Default          |
|------------------------|------------------------------------------------------|------------------|
| `aws_region`           | AWS region                                           | `us-east-1`      |
| `environment`          | Environment tag                                      | `prod`           |
| `domain_name`          | Base domain (e.g. `example.com`)                     | **required**     |
| `hosted_zone_id`       | Route53 Hosted Zone ID                               | **required**     |
| `jenkins_subdomain`    | Subdomain prefix                                     | `jenkins`        |
| `vpc_cidr`             | VPC CIDR                                             | `10.0.0.0/16`    |
| `public_subnet_cidrs`  | Public subnet CIDRs (NLB)                            | 2 × /24          |
| `private_subnet_cidrs` | Private subnet CIDRs (ALB + EC2)                     | 2 × /24          |
| `availability_zones`   | AZ list                                              | `us-east-1a/b`   |
| `instance_type`        | Jenkins EC2 instance type                            | `t3.medium`      |
| `key_name`             | EC2 key pair name                                    | **required**     |
| `ami_id`               | AMI ID (empty = auto Amazon Linux 2023)              | `""`             |
| `jenkins_port`         | Jenkins HTTP port on EC2                             | `8080`           |
| `root_volume_size`     | Root EBS size in GB                                  | `30`             |

## Outputs

| Output               | Description                             |
|----------------------|-----------------------------------------|
| `jenkins_url`        | Full HTTPS URL for Jenkins              |
| `nlb_dns_name`       | NLB DNS name                            |
| `alb_dns_name`       | Internal ALB DNS name                   |
| `ec2_instance_id`    | Jenkins EC2 instance ID                 |
| `ec2_private_ip`     | EC2 private IP                          |
| `acm_certificate_arn`| ACM certificate ARN                     |
| `vpc_id`             | VPC ID                                  |
