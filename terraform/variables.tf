# -------------------------------------------------------------
# 1. AWS CONFIGURATION
# -------------------------------------------------------------
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "snowflake-dbt-netflix-lab"
}

variable "s3_bucket_name" {
  type        = string
  description = "Globally unique name of the S3 bucket"
}

# -------------------------------------------------------------
# 2. SNOWFLAKE CONFIGURATION
# -------------------------------------------------------------
variable "snowflake_organization_name" {
  type        = string
  description = "Snowflake Organization Name"
}

variable "snowflake_account_name" {
  type        = string
  description = "Snowflake Account Name"
}

variable "snowflake_user" {
  type        = string
  description = "Snowflake Username"
}

variable "snowflake_password" {
  type        = string
  sensitive   = true
  description = "Snowflake Password"
}

variable "snowflake_role" {
  type        = string
  description = "Snowflake Role to execute commands"
}

variable "storage_aws_iam_user_arn" {
  type        = string
  default     = ""
}

variable "storage_aws_external_id" {
  type        = string
  default     = ""
}