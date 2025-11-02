module "vpc" {
  source = "../../modules/vpc"

  project          = var.project
  env              = var.env
  vpc_cidr         = var.vpc_cidr
  azs              = var.azs
  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  database_subnets = var.database_subnets
}

module "sg" {
  source = "../../modules/sg"
  vpc_id = module.vpc.vpc_id
}

module "alb" {
  source         = "../../modules/alb"
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
  alb_sg_id      = module.sg.alb_sg_id
}

module "cloudwatch" {
  source = "../../modules/cloudwatch"

  project = var.project
  env     = var.env

  alb_lb_arn_suffix = module.alb.lb_arn_suffix
  alb_tg_arn_suffix = module.alb.tg_arn_suffix

  ec2_instance_ids = module.ec2.instance_ids   # ← 传入 EC2 实例 ID 列表

  sns_email = var.alert_email
}

module "vpce" {
  source          = "../../modules/vpce"
  project         = var.project
  env             = var.env
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  vpc_cidr        = var.vpc_cidr
  ec2_sg_id       = module.sg.ec2_sg_id   # ← 这个名字要和变量一致
}

module "ec2" {
  source = "../../modules/ec2"

  project          = var.project
  env              = var.env
  subnets          = module.vpc.private_subnets
  ec2_sg_id        = module.sg.ec2_sg_id
  target_group_arn = module.alb.target_group_arn
  instance_type    = var.instance_type
  desired_count    = var.desired_count
}

