variable "hosted_zone_id" {
  description = "Route53 Hosted Zone ID"
  type        = string
}

variable "jenkins_subdomain" {
  description = "Subdomain prefix for Jenkins (e.g. 'jenkins')"
  type        = string
}

variable "domain_name" {
  description = "Base domain name (e.g. 'example.com')"
  type        = string
}

variable "nlb_dns_name" {
  description = "DNS name of the NLB to point the alias at"
  type        = string
}

variable "nlb_zone_id" {
  description = "Hosted zone ID of the NLB (for alias record)"
  type        = string
}
