variable "name" {
  description = "Name prefix (must start with transform-demo-)"
  type        = string

  validation {
    condition     = startswith(var.name, "transform-demo-")
    error_message = "The deploy permission set scopes named resources to transform-demo-*; the name must start with transform-demo-."
  }
}

variable "db_subnet_group_name" {
  description = "RDS subnet group (created by the network module)"
  type        = string
}

variable "rds_sg_id" {
  description = "Security group for the RDS instance"
  type        = string
}
