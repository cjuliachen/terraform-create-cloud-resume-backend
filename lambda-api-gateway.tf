# Lambda
resource "aws_lambda_function" "lambda" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = var.lambda_function_name
  role          = aws_iam_role.role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = var.lambda_runtime
  depends_on    = [aws_cloudwatch_log_group.lambda_log]

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  environment {
    variables = {
      table_name  = "${var.dynamodb_table_name}",
      domain_name = "${var.endpoint}"
    }
  }
  tags = local.tags
}

resource "aws_cloudwatch_log_group" "lambda_log" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = var.lambda_log_retention
}



## assume role for basic lambda
resource "aws_iam_role" "role" {
  name               = "lambda-role-${var.lambda_function_name}"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = local.tags
}

## assign policy to access Dynamo DB
resource "aws_iam_role_policy" "lambda_policy" {
  name   = "lambda_dynamodb_policy"
  role   = aws_iam_role.role.id
  policy = data.aws_iam_policy_document.dynamodb_access.json

}

resource "aws_iam_role_policy_attachment" "lambda_basic_executin_rule" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}



# HTTP API Gateway
resource "aws_apigatewayv2_api" "lambda" {
  name          = "${var.lambda_function_name}-http-api"
  protocol_type = "HTTP"
  tags          = local.tags
  description   = "HTTP API Gateway for ${var.lambda_function_name}"

  cors_configuration {
    allow_credentials = false
    allow_headers = [
      "content-type"
    ]
    allow_methods = [
      "OPTIONS",
      "POST"
    ]
    allow_origins = [
      "https://${var.endpoint}",
      "https://${var.domain_name}",
      "https://www.${var.domain_name}"
    ]
    expose_headers = []
    max_age        = 0
  }

}


resource "aws_apigatewayv2_stage" "default" {
  api_id = aws_apigatewayv2_api.lambda.id

  name        = "$default"
  auto_deploy = true

  # Default throttling settings
  default_route_settings {
    throttling_burst_limit = 10
    throttling_rate_limit  = 100
  }
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
  depends_on = [aws_cloudwatch_log_group.api_gw]
}

resource "aws_apigatewayv2_integration" "app" {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri  = aws_lambda_function.lambda.invoke_arn
  integration_type = "AWS_PROXY"
}

resource "aws_apigatewayv2_route" "post" {
  api_id    = aws_apigatewayv2_api.lambda.id
  route_key = "POST /${var.lambda_function_name}"
  target    = "integrations/${aws_apigatewayv2_integration.app.id}"
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name              = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}"
  retention_in_days = var.apigw_log_retention
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}
