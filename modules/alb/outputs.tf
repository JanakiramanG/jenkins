output "alb_arn" {
  description = "ARN of the internal ALB"
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "DNS name of the internal ALB (used as NLB target)"
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = "Hosted zone ID of the internal ALB"
  value       = aws_lb.this.zone_id
}

output "target_group_arn" {
  description = "ARN of the Jenkins target group"
  value       = aws_lb_target_group.jenkins.arn
}
