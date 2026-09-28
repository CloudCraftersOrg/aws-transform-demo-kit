variable "name" {
  description = "Name prefix for all network resources (must start with transform-demo-)"
  type        = string

  validation {
    condition     = startswith(var.name, "transform-demo-")
    error_message = "The deploy permission set scopes named resources to transform-demo-*; the name must start with transform-demo-."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "az_count" {
  description = "Number of availability zones"
  type        = number
}
