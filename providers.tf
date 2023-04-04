provider "aws" {
  region = var.my_aws_region
}

# Region alias to use for Cloudfront
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}
