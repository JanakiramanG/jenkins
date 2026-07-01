output "jenkins_url" {
  description = "Public URL to access Jenkins"
  value       = "https://${var.jenkins_subdomain}.${var.domain_name}"
}

output "nlb_dns_name" {
  description = "DNS name of the Network Load Balancer"
  value       = module.nlb.nlb_dns_name
}

output "alb_dns_name" {
  description = "DNS name of the internal Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "ec2_instance_id" {
  description = "Jenkins EC2 instance ID"
  value       = module.ec2.instance_id
}

output "ec2_private_ip" {
  description = "Private IP of the Jenkins EC2 instance"
  value       = module.ec2.private_ip
}

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = module.acm.certificate_arn
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}
