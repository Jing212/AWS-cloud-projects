output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "database_subnets" {
  value = module.vpc.database_subnets
}

output "alb_sg_id" {
  value = module.sg.alb_sg_id
}

output "ec2_sg_id" {
  value = module.sg.ec2_sg_id
}

output "rds_sg_id" {
  value = module.sg.rds_sg_id
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "alb_target_group_arn" {
  value = module.alb.target_group_arn
}
