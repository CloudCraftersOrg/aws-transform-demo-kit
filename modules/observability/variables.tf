variable "name" {
  description = "Name prefix (must start with transform-demo-)"
  type        = string

  validation {
    condition     = startswith(var.name, "transform-demo-")
    error_message = "The deploy permission set scopes named resources to transform-demo-*; the name must start with transform-demo-."
  }
}

variable "alb_arn_suffix" {
  type = string
}

variable "web_tg_arn_suffix" {
  type = string
}

variable "nlb_arn_suffix" {
  type = string
}

variable "app_tg_arn_suffix" {
  type = string
}

variable "db_identifier" {
  type = string
}
