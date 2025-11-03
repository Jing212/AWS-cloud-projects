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

module "rds" {
  source = "../../modules/rds"

  project          = var.project
  env              = var.env
  vpc_id           = module.vpc.vpc_id
  database_subnets = module.vpc.database_subnets

  # 允许从 EC2 安全组访问数据库
  allowed_sg_ids = {
  ec2 = module.sg.ec2_sg_id
}


  # 选择引擎/版本/端口（以下为 MySQL 示例）
  engine         = "mysql"
  port           = 3306

  # 规格与容量
  instance_class        = var.rds_instance_class
  allocated_storage     = 20
  max_allocated_storage = 100
  multi_az              = true

  # 初始库与账号
  db_name            = "appdb"
  db_master_username = "adminuser"
  db_master_password = var.rds_master_password  # ← 从 dev.tfvars/环境变量传入

  # 安全与备份
  storage_encrypted        = true
  kms_key_id               = null
  backup_retention_period  = 7
  backup_window            = "19:00-21:00"
  maintenance_window       = "sun:22:00-sun:23:00"
  deletion_protection      = true

  # 性能监控（可先关）
  performance_insights_enabled = false
  monitoring_interval          = 0

  # 参数组（MySQL 8.0）
  parameter_group_family = "mysql8.0"
  parameters            = []

  apply_immediately = false

  tags = {
    Owner = "platform"
  }
}

