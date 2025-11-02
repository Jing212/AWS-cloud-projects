locals { name = "${var.project}-${var.env}" }

data "aws_region" "current" {}
data "aws_vpc" "this" { id = var.vpc_id }

# VPCE 专用 SG：只允许来自 EC2-SG 的 443
resource "aws_security_group" "vpce" {
  name   = "${local.name}-vpce-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [var.ec2_sg_id]   # <-- 用到你传进来的 ec2_sg_id
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3 个 Interface Endpoint（挂私有子网 + 上面的 SG）
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnets
  security_group_ids  = [aws_security_group.vpce.id]
  private_dns_enabled = true
  tags = { Name = "${local.name}-vpce-ssm" }
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnets
  security_group_ids  = [aws_security_group.vpce.id]
  private_dns_enabled = true
  tags = { Name = "${local.name}-vpce-ssmmessages" }
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnets
  security_group_ids  = [aws_security_group.vpce.id]
  private_dns_enabled = true
  tags = { Name = "${local.name}-vpce-ec2messages" }
}

# S3 Gateway Endpoint（挂 VPC 主路由表）
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [data.aws_vpc.this.main_route_table_id]  # 注意这里的属性名
  tags = { Name = "${local.name}-vpce-s3" }
}

# CloudWatch Logs Interface Endpoint（供 CloudWatch Agent 走内网上报）
resource "aws_vpc_endpoint" "logs" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnets
  security_group_ids  = [aws_security_group.vpce.id]  # 复用你上面创建的 VPCE SG
  private_dns_enabled = true
  tags = { Name = "${local.name}-vpce-logs" }
}
