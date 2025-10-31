# VPC
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "${var.project}-${var.env}-vpc"
    Project = var.project
    Env     = var.env
  }
}

# 公有子网
resource "aws_subnet" "public" {
  for_each = toset(var.public_subnets)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = var.azs[index(var.public_subnets, each.value)]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project}-${var.env}-public-${each.value}"
  }
}

# 私有子网
resource "aws_subnet" "private" {
  for_each = toset(var.private_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = var.azs[index(var.private_subnets, each.value)]

  tags = {
    Name = "${var.project}-${var.env}-private-${each.value}"
  }
}

# 数据库子网
resource "aws_subnet" "db" {
  for_each = toset(var.database_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = var.azs[index(var.database_subnets, each.value)]

  tags = {
    Name = "${var.project}-${var.env}-db-${each.value}"
  }
}

# ========== Internet 访问（仅公有子网用） ==========
# 1) Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "${var.project}-${var.env}-igw" }
}

# 2) Public Route Table（走 IGW）
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.project}-${var.env}-public-rtb" }
}

# 3) 默认路由：0.0.0.0/0 → IGW
resource "aws_route" "public_default" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# 4) 只把“public 子网”关联到这张 Public RTB
resource "aws_route_table_association" "public_assoc" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}


# locals 统一对外输出
locals {
  vpc_id           = aws_vpc.this.id
  public_subnets   = [for s in aws_subnet.public  : s.id]
  private_subnets  = [for s in aws_subnet.private : s.id]
  database_subnets = [for s in aws_subnet.db      : s.id]
}
