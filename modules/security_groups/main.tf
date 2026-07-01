# ─────────────────────────────────────────────────────────────────────────────
# Security Groups Module
#   - nlb_sg   : NLB (internet-facing, allow inbound TCP 443)
#   - alb_sg   : ALB (allow inbound HTTPS 443 from NLB only)
#   - ec2_sg   : EC2 (allow inbound 8080 from ALB only, outbound unrestricted)
# ─────────────────────────────────────────────────────────────────────────────

# ── NLB Security Group ────────────────────────────────────────────────────────
# NLB is layer-4; AWS does not attach SGs to NLBs directly.
# This SG is kept for documentation / future TLS-offload on NLB use-cases.
# The real enforcement is done by EC2/ALB SGs restricting source.

resource "aws_security_group" "nlb" {
  name        = "${var.environment}-jenkins-nlb-sg"
  description = "NLB: allow inbound TCP 443 from anywhere (hybrid cloud)"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS from internet/on-prem"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-jenkins-nlb-sg"
  }
}

# ── ALB Security Group ────────────────────────────────────────────────────────
resource "aws_security_group" "alb" {
  name        = "${var.environment}-jenkins-alb-sg"
  description = "ALB: allow HTTPS 443 from VPC (NLB forwards here)"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS from within VPC (NLB target)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Forward to Jenkins EC2 on jenkins_port"
    from_port   = var.jenkins_port
    to_port     = var.jenkins_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name = "${var.environment}-jenkins-alb-sg"
  }
}

# ── EC2 Security Group ────────────────────────────────────────────────────────
resource "aws_security_group" "ec2" {
  name        = "${var.environment}-jenkins-ec2-sg"
  description = "EC2: allow jenkins_port from ALB SG only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Jenkins port from ALB"
    from_port       = var.jenkins_port
    to_port         = var.jenkins_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow all outbound (yum, plugin downloads)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-jenkins-ec2-sg"
  }
}
