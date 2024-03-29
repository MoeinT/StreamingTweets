variable "env" {
  description = "Environment for resources"
  type        = string
  validation {
    condition     = contains(["dev", "prod"], var.env)
    error_message = "Environment should be either: dev or prod."
  }
}

variable "moein_obj_id" {
  type      = string
  sensitive = true
}

variable "github_token" {
  type      = string
  sensitive = true
}

variable "db_objid" {
  type      = string
  sensitive = true
}