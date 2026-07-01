# ─────────────────────────────────────────────────────────────────────────────
# Root orchestrator — calls each module in dependency order
# ─────────────────────────────────────────────────────────────────────────────

# ── 1. VPC ────────────────────────────────────────────────────────────────────
module "vpc" {
  source = "./modules/vpc"

  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

# ── 2. Security Groups ────────────────────────────────────────────────────────
module "security_groups" {
  source = "./modules/security_groups"

  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  vpc_cidr     = var.vpc_cidr
  jenkins_port = var.jenkins_port
}

# ── 3. ACM Certificate ────────────────────────────────────────────────────────
module "acm" {
  source = "./modules/acm"

  domain_name    = "${var.jenkins_subdomain}.${var.domain_name}"
  hosted_zone_id = var.hosted_zone_id
  environment    = var.environment
}

# ── 4. EC2 Jenkins instance (private subnet) ─────────────────────────────────
module "ec2" {
  source = "./modules/ec2"

  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  private_subnet_id = module.vpc.private_subnet_ids[0]
  ec2_sg_id         = module.security_groups.ec2_sg_id
  instance_type     = var.instance_type
  key_name          = var.key_name
  ami_id            = var.ami_id
  jenkins_port      = var.jenkins_port
  root_volume_size  = var.root_volume_size
}

# ── 5. ALB (internal, private subnets, HTTPS 443 → EC2:jenkins_port) ─────────
module "alb" {
  source = "./modules/alb"

  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  alb_sg_id           = module.security_groups.alb_sg_id
  certificate_arn     = module.acm.certificate_arn
  jenkins_port        = var.jenkins_port
  jenkins_instance_id = module.ec2.instance_id

  depends_on = [module.acm, module.ec2]
}

# ── 6. NLB (internet-facing / hybrid, public subnets, TCP 443 → ALB) ─────────
module "nlb" {
  source = "./modules/nlb"

  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_dns_name      = module.alb.alb_dns_name
  alb_arn           = module.alb.alb_arn

  depends_on = [module.alb]
}

# ── 7. Route53 record: jenkins.<domain> → NLB ────────────────────────────────
module "route53" {
  source = "./modules/route53"

  hosted_zone_id    = var.hosted_zone_id
  jenkins_subdomain = var.jenkins_subdomain
  domain_name       = var.domain_name
  nlb_dns_name      = module.nlb.nlb_dns_name
  nlb_zone_id       = module.nlb.nlb_zone_id

  depends_on = [module.nlb]
}
