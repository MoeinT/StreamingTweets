data "azurerm_client_config" "current" {}

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