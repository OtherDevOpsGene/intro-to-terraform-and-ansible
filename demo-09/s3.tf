resource "aws_kms_key" "logging_key" {
  description             = "Logging key"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = {
    Name    = "planet-logging-key"
    Owner   = var.owner_email
    Project = var.project_tag
  }
}

resource "aws_s3_bucket" "alb_logs" {
  #checkov:skip=CKV_AWS_144:No cross-region replication since it is a demo- not good for production
  #checkov:skip=CKV_AWS_18:No logging in the logging bucket, by order of the dept. of redundancy dept.
  bucket = "planet-alb-logs"

  tags = {
    Name    = "planet-alb-logs"
    Owner   = var.owner_email
    Project = var.project_tag
  }
}

resource "aws_s3_bucket_acl" "alb_logs_acl" {
  bucket = aws_s3_bucket.alb_logs.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_versioning" "alb_logs_versioning" {
  bucket = aws_s3_bucket.alb_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.alb_logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.logging_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "alb_logs_access" {
  bucket = aws_s3_bucket.alb_logs.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}
