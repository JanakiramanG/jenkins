variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the NLB"
  type        = list(string)
}

variable "alb_dns_name" {
  description = "DNS name of the internal ALB (used for health check reference)"
  type        = string
}

variable "alb_arn" {
  description = "ARN of the internal ALB to register as NLB target"
  type        = string
}
