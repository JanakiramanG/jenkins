variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block (used to restrict ALB ingress to VPC traffic)"
  type        = string
}

variable "jenkins_port" {
  description = "Port Jenkins listens on inside EC2"
  type        = number
  default     = 8080
}
