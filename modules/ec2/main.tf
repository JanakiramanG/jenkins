# ─────────────────────────────────────────────────────────────────────────────
# EC2 Module — Jenkins instance in a private subnet
# ─────────────────────────────────────────────────────────────────────────────

# ── Auto-select latest Amazon Linux 2023 if ami_id not provided ───────────────
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  ami = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux_2023.id
}

# ── IAM role so EC2 can talk to SSM & CloudWatch ──────────────────────────────
resource "aws_iam_role" "jenkins" {
  name = "${var.environment}-jenkins-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = {
    Name = "${var.environment}-jenkins-ec2-role"
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.jenkins.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.jenkins.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "jenkins" {
  name = "${var.environment}-jenkins-ec2-profile"
  role = aws_iam_role.jenkins.name
}

# ── EC2 Instance ──────────────────────────────────────────────────────────────
resource "aws_instance" "jenkins" {
  ami                    = local.ami
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [var.ec2_sg_id]
  iam_instance_profile   = aws_iam_instance_profile.jenkins.name
  key_name               = var.key_name != "" ? var.key_name : null

  # userdata installs Jenkins on first boot
  user_data = templatefile(
    "${path.module}/userdata/jenkins_install.sh",
    { jenkins_port = var.jenkins_port }
  )

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    encrypted             = true
    delete_on_termination = true

    tags = {
      Name = "${var.environment}-jenkins-root-vol"
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"   # IMDSv2 enforced
    http_put_response_hop_limit = 1
  }

  tags = {
    Name = "${var.environment}-jenkins-ec2"
  }

  lifecycle {
    ignore_changes = [ami, user_data]
  }
}
