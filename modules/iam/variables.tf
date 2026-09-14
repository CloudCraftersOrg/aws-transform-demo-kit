variable "name" {
  description = "Name prefix for roles and instance profiles (must start with transform-demo-)"
  type        = string

  validation {
    condition     = startswith(var.name, "transform-demo-")
    error_message = "The deploy permission set scopes IAM writes to transform-demo-*; the name must start with transform-demo-."
  }
}

variable "artifacts_bucket_arn" {
  description = "ARN of the artifacts bucket both tiers read from"
  type        = string
}
