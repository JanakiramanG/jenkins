output "nlb_arn" {
  description = "ARN of the Network Load Balancer"
  value       = aws_lb.this.arn
}

output "nlb_dns_name" {
  description = "DNS name of the NLB"
  value       = aws_lb.this.dns_name
}

output "nlb_zone_id" {
  description = "Hosted zone ID of the NLB (for Route53 alias records)"
  value       = aws_lb.this.zone_id
}
