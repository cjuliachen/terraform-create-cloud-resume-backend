#### S3 bucket ####
resource "aws_s3_bucket" "website" {
  bucket        = var.bucket_name
  force_destroy = true
  tags          = local.tags
}

resource "aws_s3_bucket_acl" "s3_bucket_acl" {
  bucket = aws_s3_bucket.website.id
  acl    = "private"

}
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_bucket_sse" {
  bucket = aws_s3_bucket.website.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "s3block" {
  bucket                  = aws_s3_bucket.website.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#### Upload files to S3 bucket - replaced by GitHub Action for frontend ####
# resource "aws_s3_object" "static_files" {
#   for_each = module.template_files.files

#   bucket       = aws_s3_bucket.website.id
#   key          = each.key
#   content_type = each.value.content_type

#   source  = each.value.source_path
#   content = each.value.content

#   etag = each.value.digests.md5
# }
