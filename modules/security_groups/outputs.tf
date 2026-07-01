output "nlb_sg_id" {
  description = "Security Group ID for the NLB"
  value       = aws_security_group.nlb.id
}

output "alb_sg_id" {
  description = "Security Group ID for the ALB"
  value       = aws_security_group.alb.id
}

output "ec2_sg_id" {
  description = "Security Group ID for the Jenkins EC2 instance"
  value       = aws_security_group.ec2.id
}
