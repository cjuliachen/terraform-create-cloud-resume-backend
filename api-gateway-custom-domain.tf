resource "aws_acm_certificate" "api_cert" {
  domain_name       = var.api_domain
  validation_method = "DNS"

  tags = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "api_cert_dns" {
  allow_overwrite = true
  name            = tolist(aws_acm_certificate.api_cert.domain_validation_options)[0].resource_record_name
  records         = [tolist(aws_acm_certificate.api_cert.domain_validation_options)[0].resource_record_value]
  type            = tolist(aws_acm_certificate.api_cert.domain_validation_options)[0].resource_record_type
  zone_id         = data.aws_route53_zone.myzone.zone_id
  ttl             = 60
}

resource "aws_acm_certificate_validation" "api_cert_validate" {
  certificate_arn         = aws_acm_certificate.api_cert.arn
  validation_record_fqdns = [aws_route53_record.api_cert_dns.fqdn]
}

resource "aws_apigatewayv2_domain_name" "myapi" {
  domain_name = var.api_domain
  tags        = local.tags
  domain_name_configuration {
    certificate_arn = aws_acm_certificate.api_cert.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
  depends_on = [
    aws_acm_certificate_validation.api_cert_validate
  ]
}

resource "aws_route53_record" "myapi_dns" {
  name    = aws_apigatewayv2_domain_name.myapi.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.myzone.zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.myapi.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.myapi.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_apigatewayv2_api_mapping" "myapi_mapping" {
  api_id      = aws_apigatewayv2_api.lambda.id
  domain_name = aws_apigatewayv2_domain_name.myapi.id
  stage       = aws_apigatewayv2_stage.default.id
}
