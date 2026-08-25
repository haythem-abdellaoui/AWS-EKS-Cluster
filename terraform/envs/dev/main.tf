module "vpc" {
  source      = "../../modules/vpc"
  environment = var.environment
}

module "ecr" {
  source      = "../../modules/ecr"
  app_name    = "demo-app"
  environment = var.environment
}

module "eks" {
  source       = "../../modules/eks"
  cluster_name = "aws-eks-cluster"
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnet_ids
}

module "rds" {
  source                = "../../modules/rds"
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  db_subnet_group_name  = module.vpc.db_subnet_group_name
  eks_security_group_id = module.eks.eks_security_group_id
}