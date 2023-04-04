terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.5"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.3.0"
    }
  }
  #save Terraform state to S3 bucket and use DynomoDB for state locking
  backend "s3" {
    bucket = "YOUR-TERRAFORM-STATE-S3-BUCKET"
    key    = "cloud-resume-infra-code/terraform.tfstate"
    region = "YOUR-REGION"

    dynamodb_table = "YOUR-DDB-TABLE-FOR-TF-STATE-LOCKS"
    encrypt        = true
    profile        = "mfa"
  }
}


locals {
  account_id = data.aws_caller_identity.current.account_id
  tags = {
    project    = var.project_name
    created_by = "terraform"
  }
}

### only needed when uploading files to S3 -- replaced by GitHub frontend pipeline ###
# module "template_files" {
#   source   = "hashicorp/dir/template"
#   version  = "1.0.2"
#   base_dir = "${abspath(path.root)}/${var.site_content_source}"
# }
