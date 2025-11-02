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
