output "vpc_id" {
  description = "The ID of the VPC"
  value       = local.vpc_id
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = local.public_subnets
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = local.private_subnets
}

output "database_subnets" {
  description = "List of database subnet IDs"
  value       = local.database_subnets
}

output "igw_id"                { value = aws_internet_gateway.igw.id }
output "public_route_table_id" { value = aws_route_table.public.id }
