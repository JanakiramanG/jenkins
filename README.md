# Jenkins on AWS — Hybrid Cloud Terraform (Modular)

**Author:** janakiraman_g  
**Date:** January 2026

---

## Overview

This Terraform project provisions a production-ready Jenkins setup on AWS using a modular architecture. Traffic flows from a hybrid-cloud DNS entry through a Network Load Balancer (NLB) to an internal Application Load Balancer (ALB) which terminates TLS using an ACM certificate, and forwards requests to a Jenkins EC2 instance running in a private subnet.

---

## Architecture

```
Internet / On-Prem
        │
        ▼
Route53  (A alias)
jenkins.<domain_name>
        │
        ▼
┌──────────────────────────────────┐
│  Network Load Balancer  (NLB)    │
│  Scheme  : internet-facing       │
│  Subnets : Public                │
│  Listener: TCP  443              │
│  Target  : ALB (type = alb)      │
└───────────────┬──────────────────┘
                │  TCP 443
                ▼
┌──────────────────────────────────┐
│  Application Load Balancer (ALB) │
│  Scheme  : internal              │
│  Subnets : Private               │
│  Listener: HTTPS 443             │
│  TLS cert: ACM (DNS validated)   │
│  Target  : EC2 :8080             │
└───────────────┬──────────────────┘
                │  HTTP 8080
                ▼
┌──────────────────────────────────┐
│  EC2 Instance  (private subnet)  │
│  OS      : Amazon Linux 2023     │
│  Jenkins installed via userdata  │
│  IMDSv2 enforced                 │
│  IAM role: SSM + CloudWatch      │
└──────────────────────────────────┘
```

---

## Module Structure

```
jenkins/
├── main.tf                          # Root — wires all modules together
├── variables.tf                     # Root input variables
├── outputs.tf                       # Root outputs
├── versions.tf                      # Terraform & provider version pins
├── terraform.tfvars.example         # Copy → terraform.tfvars and fill in
└── modules/
    ├── vpc/                         # VPC, subnets, IGW, NAT GW, route tables
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── security_groups/             # SGs for NLB, ALB, EC2
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── acm/                         # ACM certificate + Route53 DNS validation
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── ec2/                         # Jenkins EC2, IAM role, userdata
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── userdata/
    │       └── jenkins_install.sh   # Installs Java 17, Jenkins, CloudWatch agent
    ├── alb/                         # Internal ALB, HTTPS listener, TG → EC2
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── nlb/                         # Internet-facing NLB, TCP 443, ALB as target
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── route53/                     # A alias record jenkins.<domain> → NLB
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

---

## Prerequisites

- Terraform >= 1.5
- AWS CLI configured (`aws configure` or environment variables)
- A Route53 **public** hosted zone for your domain
- An EC2 key pair (optional — SSM Session Manager works without one)

---

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/JanakiramanG/jenkins.git
cd jenkins

# 2. Copy and edit the variables file
cp terraform.tfvars.example terraform.tfvars
# Fill in: domain_name, hosted_zone_id, key_name

# 3. Initialise and deploy
terraform init
terraform plan
terraform apply
```

After `apply` completes, Jenkins is available at:

```
https://jenkins.<your-domain>
```

---

## Retrieve Jenkins Initial Admin Password

No bastion host is needed — use AWS SSM Session Manager:

```bash
# Start a session on the Jenkins EC2
aws ssm start-session --target <ec2_instance_id>

# Inside the session
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

---

## Input Variables

| Variable               | Description                                           | Default           |
|------------------------|-------------------------------------------------------|-------------------|
| `aws_region`           | AWS region to deploy resources                        | `us-east-1`       |
| `environment`          | Environment tag (prod, dev, staging)                  | `prod`            |
| `domain_name`          | Base domain managed in Route53 (e.g. `example.com`)  | **required**      |
| `hosted_zone_id`       | Route53 Hosted Zone ID                                | **required**      |
| `jenkins_subdomain`    | Subdomain prefix for Jenkins                          | `jenkins`         |
| `vpc_cidr`             | VPC CIDR block                                        | `10.0.0.0/16`     |
| `public_subnet_cidrs`  | CIDRs for public subnets (NLB)                        | 2 × /24           |
| `private_subnet_cidrs` | CIDRs for private subnets (ALB + EC2)                 | 2 × /24           |
| `availability_zones`   | List of AZs                                           | `us-east-1a/1b`   |
| `instance_type`        | Jenkins EC2 instance type                             | `t3.medium`       |
| `key_name`             | EC2 key pair name (empty = no SSH key)                | **required**      |
| `ami_id`               | AMI ID (empty = auto Amazon Linux 2023)               | `""`              |
| `jenkins_port`         | Jenkins HTTP port on EC2                              | `8080`            |
| `root_volume_size`     | Root EBS volume size in GB                            | `30`              |

---

## Outputs

| Output                | Description                              |
|-----------------------|------------------------------------------|
| `jenkins_url`         | Full HTTPS URL for Jenkins               |
| `nlb_dns_name`        | DNS name of the NLB                      |
| `alb_dns_name`        | DNS name of the internal ALB             |
| `ec2_instance_id`     | Jenkins EC2 instance ID                  |
| `ec2_private_ip`      | Private IP of the Jenkins EC2            |
| `acm_certificate_arn` | ARN of the ACM TLS certificate           |
| `vpc_id`              | VPC ID                                   |

---

## Security Highlights

- EC2 in a **private subnet** — not directly reachable from the internet
- TLS terminated at the **ALB** using an ACM-managed certificate
- **IMDSv2** enforced on the EC2 instance (token-based metadata)
- Security groups follow least-privilege: EC2 only accepts traffic from the ALB SG
- EBS root volume is **encrypted**
- SSM Session Manager enabled — no inbound SSH port required

---

## License

MIT
