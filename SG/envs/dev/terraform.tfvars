project = "hama-3tier"
env     = "dev"
region  = "ap-northeast-1"

vpc_cidr = "10.0.0.0/16"
azs      = ["ap-northeast-1a", "ap-northeast-1c"]

public_subnets   = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets  = ["10.0.3.0/24", "10.0.4.0/24"]
database_subnets = ["10.0.5.0/24", "10.0.6.0/24"]
