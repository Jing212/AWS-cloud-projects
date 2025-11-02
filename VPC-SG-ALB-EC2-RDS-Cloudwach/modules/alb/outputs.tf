# 原有输出
output "alb_dns_name"     { value = aws_lb.this.dns_name }
output "target_group_arn" { value = aws_lb_target_group.this.arn }

# 新增给 CloudWatch 用
output "lb_arn_suffix" {
  description = "CloudWatch dimension: LoadBalancer"
  value       = aws_lb.this.arn_suffix
}

output "tg_arn_suffix" {
  description = "CloudWatch dimension: TargetGroup"
  value       = aws_lb_target_group.this.arn_suffix
}
