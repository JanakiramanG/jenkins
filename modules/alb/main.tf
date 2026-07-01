# ─────────────────────────────────────────────────────────────────────────────
# ALB Module — Internal ALB in private subnets
#   Listener  : HTTPS 443 with ACM certificate
#   Target    : EC2 instance on jenkins_port (HTTP)
# ─────────────────────────────────────────────────────────────────────────────

# ── Application Load Balancer ─────────────────────────────────────────────────
resource "aws_lb" "this" {
  name               = "${var.environment}-jenkins-alb"
  internal           = true          # private — NLB fronts it
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.private_subnet_ids

  enable_deletion_protection = false

  access_logs {
    bucket  = ""
    enabled = false
  }

  tags = {
    Name = "${var.environment}-jenkins-alb"
  }
}

# ── Target Group: EC2 on jenkins_port ────────────────────────────────────────
resource "aws_lb_target_group" "jenkins" {
  name        = "${var.environment}-jenkins-tg"
  port        = var.jenkins_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/login"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 10
    interval            = 30
    matcher             = "200,403"   # Jenkins returns 403 before setup completes
  }

  tags = {
    Name = "${var.environment}-jenkins-tg"
  }
}

# ── Register Jenkins EC2 in the target group ──────────────────────────────────
resource "aws_lb_target_group_attachment" "jenkins" {
  target_group_arn = aws_lb_target_group.jenkins.arn
  target_id        = var.jenkins_instance_id
  port             = var.jenkins_port
}

# ── HTTPS Listener: 443 → target group ───────────────────────────────────────
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins.arn
  }

  tags = {
    Name = "${var.environment}-jenkins-alb-https-listener"
  }
}

# ── HTTP Listener: 80 → redirect to HTTPS ────────────────────────────────────
resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = {
    Name = "${var.environment}-jenkins-alb-http-redirect"
  }
}
