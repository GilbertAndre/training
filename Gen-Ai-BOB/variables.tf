# ── General ────────────────────────────────────────────────────────────────

variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefix used for all resource names"
  type        = string
  default     = "genai-app"
}

# ── Lambda ─────────────────────────────────────────────────────────────────

variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.12"
}

variable "lambda_handler" {
  description = "Lambda handler in format filename.function_name"
  type        = string
  default     = "lambda_function.handler"
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 60
}

variable "lambda_memory" {
  description = "Lambda memory size in MB"
  type        = number
  default     = 128
}

# ── Secrets Manager ────────────────────────────────────────────────────────

variable "secret_name" {
  description = "Full name of the secret in Secrets Manager the Lambda will fetch"
  type        = string
  default     = "genai-app/rds-credentials"
}

variable "secret_name_prefix" {
  description = "Prefix to scope the Secrets Manager IAM policy"
  type        = string
  default     = "genai-app/"
}
