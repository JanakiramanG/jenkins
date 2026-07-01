# ── General ───────────────────────────────────────────────────────────────────
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (e.g. prod, dev, staging)"
  type        = string
  default     = "prod"
}

# ── DNS / Domain ──────────────────────────────────────────────────────────────
variable "domain_name" {
  description = "Base domain name managed in Route53 (e.g. example.com)"
  type        = string
}

variable "hosted_zone_id" {
  description = "Route53 Hosted Zone ID for the domain"
  type        = string
}

variable "jenkins_subdomain" {
  description = "Subdomain prefix for Jenkins (results in jenkins.<domain_name>)"
  type        = string
  default     = "jenkins"
}

# ── VPC ───────────────────────────────────────────────────────────────────────
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (NLB lives here)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (ALB + EC2 live here)"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# ── EC2 / Jenkins ─────────────────────────────────────────────────────────────
variable "instance_type" {
  description = "EC2 instance type for Jenkins"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "Name of the EC2 key pair for SSH access"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the Jenkins EC2 instance (Amazon Linux 2023 recommended)"
  type        = string
  default     = ""   # If empty, latest Amazon Linux 2023 is fetched automatically
}

variable "jenkins_port" {
  description = "Port Jenkins listens on inside the EC2 instance"
  type        = number
  default     = 8080
}

variable "root_volume_size" {
  description = "Root EBS volume size in GB for Jenkins EC2"
  type        = number
  default     = 30
}
