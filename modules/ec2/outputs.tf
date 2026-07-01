output "instance_id" {
  description = "Jenkins EC2 instance ID"
  value       = aws_instance.jenkins.id
}

output "private_ip" {
  description = "Private IP address of the Jenkins EC2 instance"
  value       = aws_instance.jenkins.private_ip
}

output "iam_role_arn" {
  description = "IAM role ARN attached to the Jenkins EC2 instance"
  value       = aws_iam_role.jenkins.arn
}
