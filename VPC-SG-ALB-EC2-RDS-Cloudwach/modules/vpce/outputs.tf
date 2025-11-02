output "vpce_sg_id" { value = aws_security_group.vpce.id }

output "vpce_ids" {
  value = {
    ssm         = aws_vpc_endpoint.ssm.id
    ssmmessages = aws_vpc_endpoint.ssmmessages.id
    ec2messages = aws_vpc_endpoint.ec2messages.id
    s3_gateway  = aws_vpc_endpoint.s3.id
  }
}
output "vpce_logs_dns_entries" {
  value       = aws_vpc_endpoint.logs.dns_entry
  description = "Private DNS names and IPs of the Logs VPCE"
}
