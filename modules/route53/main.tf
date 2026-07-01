# ─────────────────────────────────────────────────────────────────────────────
# Route53 Module — Alias record: jenkins.<domain> → NLB
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_route53_record" "jenkins" {
  zone_id = var.hosted_zone_id
  name    = "${var.jenkins_subdomain}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.nlb_dns_name
    zone_id                = var.nlb_zone_id
    evaluate_target_health = true
  }
}
