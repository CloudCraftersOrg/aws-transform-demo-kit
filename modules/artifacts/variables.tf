variable "bucket_name" {
  description = "Artifacts bucket name (must start with transform-demo-; the deploy permission set scopes S3 to transform-demo-*)"
  type        = string

  validation {
    condition     = startswith(var.bucket_name, "transform-demo-")
    error_message = "Bucket name must start with transform-demo-."
  }
}
