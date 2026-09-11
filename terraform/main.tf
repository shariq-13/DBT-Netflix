# =============================================================
# 1. PROVIDERS & DATA SOURCES
# =============================================================
provider "aws" {
  region = var.aws_region
}

provider "snowflake" {
  organization_name = var.snowflake_organization_name
  account_name      = var.snowflake_account_name
  user              = var.snowflake_user
  password          = var.snowflake_password
  role              = var.snowflake_role
}
# 2. AWS S3 BUCKET
# =============================================================
resource "aws_s3_bucket" "project_bucket" {
  bucket        = var.s3_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.project_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_block" {
  bucket                  = aws_s3_bucket.project_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# =============================================================
# 2. AWS IAM ROLE FOR SNOWFLAKE
# =============================================================
resource "aws_iam_role" "snowflake_role" {
  name = "${var.project_name}-snowflake-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = var.storage_aws_iam_user_arn
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.storage_aws_external_id
          }
        }
      }
    ]
  })

  tags = {
    Name      = "${var.project_name}-snowflake-role"
    Project   = var.project_name
    ManagedBy = "Terraform"
  }
}

# =============================================================
# 3. AWS IAM POLICY & ATTACHMENT
# =============================================================
resource "aws_iam_policy" "snowflake_s3_policy" {
  name        = "${var.project_name}-snowflake-s3-policy"
  description = "Allow Snowflake to read project S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = aws_s3_bucket.project_bucket.arn
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:GetObjectVersion"]
        Resource = "${aws_s3_bucket.project_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "snowflake_s3_policy_attach" {
  role       = aws_iam_role.snowflake_role.name
  policy_arn = aws_iam_policy.snowflake_s3_policy.arn
}

# =============================================================
# 4. SNOWFLAKE STORAGE INTEGRATION
# =============================================================
resource "snowflake_storage_integration_aws" "s3_integration" {
  name                      = "S3_SNOWFLAKE_INTEGRATION"
  enabled                   = true
  storage_provider          = "S3"
  storage_aws_role_arn      = aws_iam_role.snowflake_role.arn
  storage_allowed_locations = ["s3://${aws_s3_bucket.project_bucket.bucket}/"]
}

# =============================================================
# 5. UPLOAD DATA TO EXISTING S3 BUCKET
# =============================================================
resource "aws_s3_object" "raw_datasets" {
  for_each = fileset("${path.module}/data", "**/*.csv")

  bucket = aws_s3_bucket.project_bucket.id
  key    = "raw/${each.value}"
  source = "${path.module}/data/${each.value}"
  etag   = filemd5("${path.module}/data/${each.value}")
}