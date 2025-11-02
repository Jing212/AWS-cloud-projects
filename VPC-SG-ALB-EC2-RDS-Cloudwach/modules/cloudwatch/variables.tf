variable "project" { type = string }
variable "env"     { type = string }

# ALB 的维度（来自 ALB 模块输出）
variable "alb_lb_arn_suffix" { type = string }
variable "alb_tg_arn_suffix" { type = string }

# 接收告警的邮箱
variable "sns_email" { type = string }

variable "ec2_instance_ids" {
  description = "List of EC2 instance IDs"
  type        = list(string)
  default     = []
}
