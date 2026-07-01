variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the ALB"
  type        = list(string)
}

variable "alb_sg_id" {
  description = "Security Group ID to attach to the ALB"
  type        = string
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate for HTTPS termination"
  type        = string
}

variable "jenkins_port" {
  description = "Port Jenkins listens on inside EC2"
  type        = number
  default     = 8080
}

variable "jenkins_instance_id" {
  description = "EC2 instance ID of the Jenkins server"
  type        = string
}
