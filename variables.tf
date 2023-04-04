variable "my_aws_region" {
  description = "AWS Region"
  type        = string
}

variable "project_name" {
  description = "Project name for taggaing"
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "endpoint" {
  description = "Endpoint URL"
  type        = string
}

variable "domain_name" {
  description = "Base Domain name"
  type        = string
}

variable "api_domain" {
  description = "Sub domain name for API"
  type        = string
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name"
  type        = string
}

variable "lambda_function_name" {
  description = "Lambda function name, same as the script name without the extention"
  type        = string
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
}

variable "lambda_log_retention" {
  description = "lambda log retention in days"
  type        = number
  default     = 7
}

variable "apigw_log_retention" {
  description = "api gwy log retention in days"
  type        = number
  default     = 7
}
