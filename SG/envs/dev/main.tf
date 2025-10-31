module "vpc" {
  source = "../../modules/vpc"

  project          = var.project
  env              = var.env
  vpc_cidr         = var.vpc_cidr
  azs              = var.azs
  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  database_subnets = var.database_subnets
}

module "sg" {
  source = "../../modules/sg"
  vpc_id = module.vpc.vpc_id
}
