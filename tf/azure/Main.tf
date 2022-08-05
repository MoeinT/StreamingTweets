terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
  }

}


data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "TerraformingAzureRg" {
  name     = "StreamingData-rg-${var.env}"
  location = "France Central"

  tags = {
    managed-by  = "Terraform"
    environment = var.env
    contact     = "moin.torabi@gmail.com"
  }
}

#Adding the required secrets to Github
resource "github_actions_secret" "actions_secret" {
  for_each = {
    ARM_CLIENT_ID       = azuread_service_principal.gh_actions.application_id
    ARM_CLIENT_SECRET   = azuread_application_password.Github-actions.value
    ARM_SUBSCRIPTION_ID = data.azurerm_subscription.current.subscription_id
    ARM_TENANT_ID       = data.azurerm_client_config.current.tenant_id
    ARM_GITHUB_TOKEN    = var.github_token
  }

  repository      = var.github_repository
  secret_name     = each.key
  plaintext_value = each.value
}