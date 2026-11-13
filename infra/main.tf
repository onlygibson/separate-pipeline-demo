# Platform resources. They exist before any app is deployed and change rarely.
# The app pipeline never touches them.

# Bucket for build artifacts such as SBOMs.
resource "aws_s3_bucket" "artifacts" {
  bucket = "separate-pipeline-demo-artifacts"

  tags = {
    ManagedBy = "terraform"
    Project   = "separate-pipeline-demo"
  }
}

# Keep old versions, so an artifact cannot be silently overwritten or deleted.
resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Customer-managed key, so we control who can decrypt and can rotate it.
resource "aws_kms_key" "artifacts" {
  description             = "Encrypts the artifacts bucket"
  enable_key_rotation     = true
  deletion_window_in_days = 7
}

# Encrypt everything at rest with that key.
resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.artifacts.arn
    }
  }
}

# Never public, whatever anyone sets later.
resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket                  = aws_s3_bucket.artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "artifacts_bucket" {
  description = "Name of the artifacts bucket."
  value       = aws_s3_bucket.artifacts.bucket
}
