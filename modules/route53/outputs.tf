output "jenkins_fqdn" {
  description = "Fully qualified domain name for Jenkins"
  value       = aws_route53_record.jenkins.fqdn
}
