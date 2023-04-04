output "cf_arn" {
  value = aws_cloudfront_distribution.cf.arn
}

output "lambda_api_url" {
  value = aws_apigatewayv2_api.lambda.api_endpoint
}

output "api_gateway_url" {
  value = aws_apigatewayv2_domain_name.myapi.domain_name_configuration[0].target_domain_name
}
