variable "function_name" {
  type        = string
  description = "Lambda function name"
}

variable "filename" {
  type        = string
  description = "Path to lambda zip file"
}

variable "handler" {
  type        = string
  description = "Lambda handler"
}

variable "runtime" {
  type        = string
  description = "Lambda runtime"
  default     = "python3.12"
}

variable "iam_role_arn" {
  type        = string
  description = "IAM role ARN for Lambda execution"
}

variable "timeout" {
  type        = number
  description = "Lambda timeout in seconds"
  default     = 10
}

variable "environment_variables" {
  type        = map(string)
  description = "Environment variables for Lambda"
  default     = {}
}

variable "s3_bucket_arn" {
  type        = string
  description = "S3 bucket ARN allowed to invoke this Lambda"
}

variable "tags" {
  type = map(string)
  description = "tags for Lambda function"
}

variable "statement_id" {
  type = string
  description = "Statement ID for Lambda permission"
}

variable "action" {
  type = string
  description = "Action for Lambda permission"
}

variable "principal" {
  type = string
  description = "Principal for Lambda permission"
}

variable "resource_arn" {
  type = string
  description = "Resource ARN for Lambda permission"
}