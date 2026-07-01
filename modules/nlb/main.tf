# ─────────────────────────────────────────────────────────────────────────────
# NLB Module — Internet-facing (hybrid) Network Load Balancer
#   Listener  : TCP port 443
#   Target    : Internal ALB (IP target)
#
# NLB → ALB chaining pattern:
#   NLB resolves ALB DNS to IPs at registration time.
#   A Lambda-based ALB-IP-sync solution handles IP drift in production;
#   for simplicity here we use the ALB DNS name and let NLB resolve it.
#   Target type is "alb" which AWS supports natively (ALB as NLB target).
# ─────────────────────────────────────────────────────────────────────────────

# ── Network Load Balancer ─────────────────────────────────────────────────────
resource "aws_lb" "this" {
  name               = "${var.environment}-jenkins-nlb"
  internal           = false         # internet-facing for hybrid cloud access
  load_balancer_type = "network"
  subnets            = var.public_subnet_ids

  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true

  tags = {
    Name = "${var.environment}-jenkins-nlb"
  }
}

# ── Target Group: ALB as target (type = alb) ──────────────────────────────────
resource "aws_lb_target_group" "alb_target" {
  name        = "${var.environment}-jenkins-nlb-tg"
  port        = 443
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "alb"

  health_check {
    enabled             = true
    protocol            = "HTTPS"
    path                = "/login"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    matcher             = "200,403"
  }

  tags = {
    Name = "${var.environment}-jenkins-nlb-tg"
  }
}

# ── Attach ALB as target ──────────────────────────────────────────────────────
resource "aws_lb_target_group_attachment" "alb" {
  target_group_arn = aws_lb_target_group.alb_target.arn
  target_id        = var.alb_arn
  port             = 443
}

# ── TCP Listener on 443 ───────────────────────────────────────────────────────
resource "aws_lb_listener" "tcp_443" {
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target.arn
  }

  tags = {
    Name = "${var.environment}-jenkins-nlb-tcp-443"
  }
}
