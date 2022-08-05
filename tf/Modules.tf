module "azure" {
  source       = "./azure"
  env          = var.env
  moein_obj_id = var.moein_obj_id
  github_token = var.github_token
}