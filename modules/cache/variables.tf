variable "name" {
  description = "Name prefix (must start with transform-demo-)"
  type        = string

  validation {
    condition     = startswith(var.name, "transform-demo-")
    error_message = "The deploy permission set scopes named resources to transform-demo-*; the name must start with transform-demo-."
  }
}

variable "subnet_ids" {
  description = "Private data subnet IDs for the cache subnet group"
  type        = list(string)
}

variable "memcached_sg_id" {
  description = "Security group for the memcached cluster"
  type        = string
}
