output "rds_sg_id" {
  description = "RDS 安全组 ID"
  value       = aws_security_group.this.id
}

output "db_instance_id" {
  description = "RDS 实例 identifier"
  value       = aws_db_instance.this.id
}

output "db_instance_arn" {
  description = "RDS 实例 ARN"
  value       = aws_db_instance.this.arn
}

output "endpoint" {
  description = "RDS 连接地址"
  value       = aws_db_instance.this.address
}

output "port" {
  description = "RDS 端口"
  value       = aws_db_instance.this.port
}

output "resource_id" {
  description = "RDS 资源 ID（CloudWatch/PI 等可能用到）"
  value       = aws_db_instance.this.resource_id
}
