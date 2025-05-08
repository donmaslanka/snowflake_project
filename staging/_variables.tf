variable "database" {
  type    = string
  default = "TERRAFORM_DEMO_STAGING"
}

variable "env_name" {
  type    = string
  default = "STAGING"
}

variable "snowflake_private_key" {
  type        = string
  description = "Private key used to access Snowflake"
  sensitive   = true
}

variable "snowflake_username" {
  type    = string
  default = ""
}
variable "snowflake_password" {
  type        = string
  description = "value of the password used to access Snowflake"
  sensitive   = true
  # This is a sensitive variable, so it should not be hardcoded in the code.
  default = ""
}

variable "s3_bucket_name" {
  type        = string
  description = "S3 bucket name for storing Terraform state"
  default     = "tuai_remote_state"
}

variable "aws_region" {
  type        = string
  description = "AWS region for resources"
  default     = "us-west-2"
}

