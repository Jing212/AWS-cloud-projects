variable "project"         { type = string }
variable "env"             { type = string }
variable "vpc_id"          { type = string }
variable "private_subnets" { type = list(string) }
variable "vpc_cidr"        { type = string }  # 现在没直接用到，保留无妨
variable "ec2_sg_id" {
  type        = string
  description = "EC2 security group id; VPCE SG only allows 443 from this SG"
}
