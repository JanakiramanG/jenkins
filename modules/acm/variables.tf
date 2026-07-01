variable "domain_name" {
  description = "Fully qualified domain name for the certificate (e.g. jenkins.example.com)"
  type        = string
}

variable "hosted_zone_id" {
  description = "Route53 Hosted Zone ID where DNS validation records will be created"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}
