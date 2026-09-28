variable "name" {
  description = "ALB and target group name (must start with transform-demo-)"
  type        = string

  validation {
    condition     = startswith(var.name, "transform-demo-")
    error_message = "The deploy permission set scopes named resources to transform-demo-*; the name must start with transform-demo-."
  }
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  description = "Public subnet IDs"
  type        = list(string)
}

variable "security_group_id" {
  type = string
}
