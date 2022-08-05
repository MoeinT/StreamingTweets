resource "azuread_application" "terraform-github" {
  display_name = "Terraform-Github"
  owners       = [var.moein_obj_id]
}

resource "azuread_application_password" "Github-actions" {
  display_name          = "Github-actions"
  application_object_id = azuread_application.terraform-github.object_id
}

resource "azuread_service_principal" "gh_actions" {
  application_id               = azuread_application.terraform-github.application_id
  app_role_assignment_required = true
  owners                       = [var.moein_obj_id]
}

resource "azurerm_role_assignment" "gh_actions" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Owner"
  principal_id         = azuread_service_principal.gh_actions.id
}