#### Create DNS CNAME record for root domain -  can be removed when there is a dedicated root site####
resource "aws_route53_record" "websiteurl-root" {
  name    = var.domain_name
  zone_id = data.aws_route53_zone.myzone.zone_id
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cf.domain_name
    zone_id                = aws_cloudfront_distribution.cf.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "websiteurl-www" {
  name    = "www.${var.domain_name}"
  zone_id = data.aws_route53_zone.myzone.zone_id
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cf.domain_name
    zone_id                = aws_cloudfront_distribution.cf.hosted_zone_id
    evaluate_target_health = true
  }
}
