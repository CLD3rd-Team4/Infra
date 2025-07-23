
// route 53
module "route53" {
  source        = "./modules/route53"         
  domain_name   = var.service_domain          
  common_prefix = local.common_prefix        
  common_tags   = local.common_tags          
}

//cloudfront(프론트 연결)
module "cloudfront_frontend" {
  source              = "./modules/cloudfront"
  bucket_domain_name  = "placeholder.s3.amazonaws.com"  // 실제 s3 변수로 변경
  acm_certificate_arn = module.acm_frontend.certificate_arn
  common_prefix       = local.common_prefix
  common_tags         = local.common_tags
}
//cloudfront(프론트 연결)- a record
module "a_record_frontend" {
  source        = "./modules/record"
  record_type   = "A"
  zone_id       = module.route53.zone_id
  name          = "www.mapzip.shop" 
  alias_name    = module.cloudfront.domain_name
  alias_zone_id = module.cloudfront.zone_id
  
}
//cloudfront(이미지연결)
module "cloudfront_image" {
  source              = "./modules/cloudfront"
  bucket_domain_name  = "placeholder.s3.amazonaws.com"  // 실제 s3 변수로 변경
  acm_certificate_arn = module.acm_image.certificate_arn
  common_prefix       = local.common_prefix
  common_tags         = local.common_tags
}
//cloudfront(이미지연결)-a record
module "a_record_image" {
  source        = "./modules/record"
  record_type   = "A"
  zone_id       = module.route53.zone_id
  name          = "img.mapzip.shop"
  alias_name    = module.cloudfront.domain_name
  alias_zone_id = module.cloudfront.zone_id
}


# acm - CloudFront (프론트엔드용)
module "acm_frontend" {
  source                    = "./modules/acm"
  providers                 = { aws = aws.us_east_1 }
  domain_name               = "www.mapzip.shop"
  common_prefix             = local.common_prefix
  common_tags               = local.common_tags
  route53_zone_id           = module.route53.zone_id
}

# acm - Ingress(ALB) 백엔드용
module "acm_backend" {
  source                    = "./modules/acm"
  providers                 = { aws = aws }
  domain_name               = "api.mapzip.shop"
  common_prefix             = local.common_prefix
  common_tags               = local.common_tags
  route53_zone_id           = module.route53.zone_id
}
# acm - 이미지용
module "acm_image" {
  source                    = "./modules/acm"
  providers                 = { aws = aws.us_east_1 }
  domain_name               = "img.mapzip.shop"
  route53_zone_id           = module.route53.zone_id
  common_prefix             = local.common_prefix
  common_tags               = local.common_tags
}

module "ecr_backend" {
  source        = "./modules/ecr"
  name          = "backend"
  common_prefix = local.common_prefix
  common_tags   = local.common_tags
}



