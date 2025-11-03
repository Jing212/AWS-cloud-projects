terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

locals {
  name_prefix = "${var.project}-${var.env}"
  tags = merge(
    {
      Project = var.project
      Env     = var.env
      Module  = "rds"
    },
    var.tags
  )
}

# ---- DB Subnet Group ----
resource "aws_db_subnet_group" "this" {
  name       = "${local.name_prefix}-db-subnet-group"
  subnet_ids = var.database_subnets
  tags       = local.tags
}

# ---- Security Group for RDS ----
resource "aws_security_group" "this" {
  name        = "${local.name_prefix}-rds-sg"
  description = "RDS SG for ${local.name_prefix}"
  vpc_id      = var.vpc_id
  tags        = local.tags
}

# 允许来自指定 SG 的入站访问（数据库端口）
resource "aws_security_group_rule" "ingress_from_sg" {
  for_each                 = var.allowed_sg_ids
  type                     = "ingress"
  from_port                = var.port
  to_port                  = var.port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.this.id
  source_security_group_id = each.value
  description              = "Allow DB port ${var.port} from ${each.key}"
}

# 出站全放行（RDS 有些场景需要访问 KMS/监控等）
resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.this.id
  description       = "Allow all egress"
}

# ---- （可选）Parameter Group ----
resource "aws_db_parameter_group" "this" {
  name        = "${local.name_prefix}-rds-pg"
  family      = var.parameter_group_family
  description = "Parameter group for ${local.name_prefix}"

  # 常见参数例子，可按需调整
  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = local.tags
}

# ---- RDS Instance ----
resource "aws_db_instance" "this" {
  identifier                  = "${local.name_prefix}-${var.engine}"
  engine                      = var.engine
  engine_version              = var.engine_version
  instance_class              = var.instance_class

  db_name                     = var.db_name
  username                    = var.db_master_username
  password                    = var.db_master_password
  port                        = var.port

  allocated_storage           = var.allocated_storage
  max_allocated_storage       = var.max_allocated_storage

  multi_az                    = var.multi_az
  publicly_accessible         = false
  storage_encrypted           = var.storage_encrypted
  kms_key_id                  = var.kms_key_id

  backup_retention_period     = var.backup_retention_period
  backup_window               = var.backup_window
  maintenance_window          = var.maintenance_window
  copy_tags_to_snapshot       = true
  deletion_protection         = var.deletion_protection
  auto_minor_version_upgrade  = true
  allow_major_version_upgrade = var.allow_major_version_upgrade

  monitoring_interval         = var.monitoring_interval
  performance_insights_enabled = var.performance_insights_enabled
  performance_insights_kms_key_id = var.performance_insights_kms_key_id

  db_subnet_group_name        = aws_db_subnet_group.this.name
  vpc_security_group_ids      = [aws_security_group.this.id]
  parameter_group_name        = aws_db_parameter_group.this.name

  apply_immediately           = var.apply_immediately

  # 强烈建议保留最终快照；如确需跳过可改为 true
  skip_final_snapshot         = false
  final_snapshot_identifier   = "${local.name_prefix}-final-${formatdate("YYYYMMDDhhmmss", timestamp())}"

  tags = local.tags

  lifecycle {
    ignore_changes = [
      # 允许你后续通过参数组/监控等微调而不频繁替换实例
      performance_insights_kms_key_id
    ]
  }
}
