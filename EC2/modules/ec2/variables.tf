variable "project"          { type = string }
variable "env"              { type = string }
variable "subnets"          { type = list(string) }
variable "ec2_sg_id"        { type = string }
variable "target_group_arn" { type = string }
variable "instance_type" {
  type    = string
  default = "t3.micro"
}
variable "desired_count" {
  type    = number
  default = 2
}
