variable "env" {
  type = string
}

variable "moein_obj_id" {
  type      = string
  sensitive = true
}

variable "github_repository" {
  type    = string
  default = "terraforming-azure"
}

variable "github_token" {
  type      = string
  sensitive = true
}

variable "db_objid" {
  type      = string
  sensitive = true
}