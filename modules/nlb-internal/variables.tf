variable "name" {
  description = "NLB and target group name (must start with transform-demo-)"
  type        = string

  validation {
    condition     = startswith(var.name, "transform-demo-")
    error_message = "The deploy permission set scopes named resources to transform-demo-*; the name must start with transform-demo-."
  }
}

variable "vpc_id" {
  description = "VPC for the target group"
  type        = string
}

variable "subnet_ids" {
  description = "Private app subnet IDs for the NLB nodes"
  type        = list(string)
}
