variable "env" {
  description = "Environment for resources"
  type        = string
  validation {
    condition     = contains(["dev", "prod"], var.env)
    error_message = "Environment should be either: dev or prod."
  }
}