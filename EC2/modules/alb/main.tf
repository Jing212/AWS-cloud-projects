# Application Load Balancer
resource "aws_lb" "this" {
  name               = "hama-alb"
  load_balancer_type = "application"
  internal           = false                # 公网 ALB
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnets

  enable_deletion_protection = false

  tags = {
    Name = "hama-alb"
  }
}

# Target Group (EC2 后端要挂在这里)
resource "aws_lb_target_group" "this" {
  name     = "hama-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "instance" # 后面挂 EC2
}

# Listener (监听 80 → 转发到 TG)
resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
