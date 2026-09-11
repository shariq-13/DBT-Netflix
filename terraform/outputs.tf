output "s3_bucket_name" {
  description = "Created S3 Bucket Name"
  value       = aws_s3_bucket.project_bucket.bucket
}

output "storage_integration_name" {
  description = "Snowflake Storage Integration Name"
  value       = snowflake_storage_integration_aws.s3_integration.name
}

output "iam_role_arn" {
  description = "AWS IAM Role ARN"
  value       = aws_iam_role.snowflake_role.arn
}