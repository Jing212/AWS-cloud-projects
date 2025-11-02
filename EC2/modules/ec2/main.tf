locals {
  name = "${var.project}-${var.env}-app"
  tags = { Project = var.project, Env = var.env, Role = "app" }
}

data "aws_ami" "al2023" {
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
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_iam_role" "ec2_role" {
  name               = "${local.name}-role"
  assume_role_policy = jsonencode({
    Version="2012-10-17",
    Statement=[{Effect="Allow",Action="sts:AssumeRole",Principal={Service="ec2.amazonaws.com"}}]
  })
  tags = local.tags
}
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_instance_profile" "profile" {
  name = "${local.name}-profile"
  role = aws_iam_role.ec2_role.name
}

locals {
  user_data        = <<-EOF
    #!/bin/bash
    set -e
    if command -v dnf >/dev/null 2>&1 || command -v yum >/dev/null 2>&1; then
      (dnf -y install amazon-ssm-agent || yum -y install amazon-ssm-agent) || true
      systemctl enable amazon-ssm-agent || true
      systemctl restart amazon-ssm-agent || true
    elif command -v snap >/dev/null 2>&1; then
      snap install amazon-ssm-agent --classic || true
      systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service || true
      systemctl restart snap.amazon-ssm-agent.amazon-ssm-agent.service || true
    fi
    command -v python3 >/dev/null 2>&1 || (apt-get update && apt-get install -y python3) || (dnf -y install python3 || yum -y install python3)
    mkdir -p /var/www && echo '<h1>OK</h1>' >/var/www/index.html
    nohup python3 -m http.server 80 --directory /var/www/ >/var/log/http.server.log 2>&1 &
    EOF
}

resource "aws_instance" "app" {
  count                       = var.desired_count
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = element(var.subnets, count.index % length(var.subnets))
  vpc_security_group_ids      = [var.ec2_sg_id]
  iam_instance_profile        = aws_iam_instance_profile.profile.name
  associate_public_ip_address = false
  user_data                   = local.user_data
  tags = merge(local.tags, { Name = "${local.name}-${count.index}" })
}

resource "aws_lb_target_group_attachment" "attach" {
  count            = length(aws_instance.app)        # 由 desired_count 决定，plan 阶段就已知
  target_group_arn = var.target_group_arn
  target_id        = aws_instance.app[count.index].id
  port             = 80
}
