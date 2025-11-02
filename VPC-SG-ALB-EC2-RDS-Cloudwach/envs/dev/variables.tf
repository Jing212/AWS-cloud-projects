variable "project" {}
variable "env" {}
variable "region" {}
variable "vpc_cidr" {}
variable "azs" {}
variable "public_subnets" {}
variable "private_subnets" {}
variable "database_subnets" {}
variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "desired_count" {
  type    = number
  default = 2
}

variable "alert_email" {
  description = "Where to send CloudWatch alarms"
  type        = string
  default     = "jingjiaaws1@gmail.com"  # 改成你的邮箱
}
