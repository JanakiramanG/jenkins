variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_id" {
  description = "Private subnet ID where the Jenkins EC2 will be placed"
  type        = string
}

variable "ec2_sg_id" {
  description = "Security Group ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "EC2 key pair name (leave empty to disable SSH key)"
  type        = string
  default     = ""
}

variable "ami_id" {
  description = "AMI ID; leave empty to auto-select latest Amazon Linux 2023"
  type        = string
  default     = ""
}

variable "jenkins_port" {
  description = "Port Jenkins listens on"
  type        = number
  default     = 8080
}

variable "root_volume_size" {
  description = "Root EBS volume size in GB"
  type        = number
  default     = 30
}
