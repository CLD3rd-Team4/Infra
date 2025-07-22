module "dynamodb" {
  source       = "./modules/dynamodb"
  environment  = terraform.workspace
  table_name   = "reviews"
  common_tags  = local.common_tags
}

module "elasticache" {
  source                        = "./modules/elasticache"
  environment                   = terraform.workspace
  cluster_name                  = "session-cache"
  common_tags                   = local.common_tags
  elasticache_subnet_group_name = module.network.elasticache_subnet_group_name # From network module
  security_group_ids            = [module.network.elasticache_security_group_id] # From network module
}