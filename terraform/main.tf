module "vpc" {
  source       = "./modules/network/vpc"
  cidr_block   = "10.0.0.0/16"
  common_prefix = local.common_prefix
  common_tags   = local.common_tags
}

module "subnet_public" {
  source                = "./modules/network/subnet"
  vpc_id                = module.vpc.vpc_id
  cidr_block            = "10.0.1.0/24"
  availability_zone     = "ap-northeast-2a"
  map_public_ip_on_launch = true
  name                  = "public-1a"
  common_prefix         = local.common_prefix
  common_tags           = local.common_tags
}

module "igw" {
  source        = "./modules/network/igw"
  vpc_id        = module.vpc.vpc_id
  common_prefix = local.common_prefix
  common_tags   = local.common_tags
}

module "natgw" {
  source        = "./modules/network/natgw"
  subnet_id     = module.subnet_public.id
  common_prefix = local.common_prefix
  common_tags   = local.common_tags
}


// route 53
module "route53" {
  source        = "./modules/route53"         
  domain_name   = var.service_domain          
  common_prefix = local.common_prefix        
  common_tags   = local.common_tags          
}

//cloudfront
module "cloudfront" {
  source              = "./modules/cloudfront"
  bucket_domain_name  = "placeholder.s3.amazonaws.com"  // 실제 s3 변수로 변경
  acm_certificate_arn = module.acm_frontend.certificate_arn
  common_prefix       = local.common_prefix
  common_tags         = local.common_tags
}
//cloudfront- a record
module "a_record_frontend" {
  source        = "./modules/record"
  record_type   = "A"
  zone_id       = module.route53.zone_id
  name          = "www.mapzip.shop" 
  alias_name    = module.cloudfront.domain_name
  alias_zone_id = module.cloudfront.zone_id
  
}

# CloudFront (프론트엔드용)
module "acm_frontend" {
  source                    = "./modules/acm"
  providers                 = { aws = aws.us_east_1 }
  domain_name               = "www.mapzip.shop"
  common_prefix             = local.common_prefix
  common_tags               = local.common_tags
  route53_zone_id           = module.route53.zone_id
}

# Ingress(ALB) 백엔드용
module "acm_backend" {
  source                    = "./modules/acm"
  providers                 = { aws = aws }
  domain_name               = "api.mapzip.shop"
  common_prefix             = local.common_prefix
  common_tags               = local.common_tags
  route53_zone_id           = module.route53.zone_id
}

module "ecr_backend" {
  source        = "./modules/ecr"
  name          = "backend"
  common_prefix = local.common_prefix
  common_tags   = local.common_tags
}



