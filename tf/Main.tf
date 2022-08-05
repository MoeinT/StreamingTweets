terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }

    databricks = {
      source = "databricks/databricks"
    }

    github = {
      source  = "hashicorp/github"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstate22sa"
    container_name       = "tfstate-container"
  }
}


data "azurerm_client_config" "current" {
}

provider "azurerm" {
  features {}
}

provider "github" {
  token = var.github_token
}

provider "databricks" {
}

resource "azurerm_resource_group" "tfstate" {
  name     = "tfstate-rg"
  location = "France Central"
}

resource "azurerm_storage_account" "tfstate" {
  name                      = "tfstate22sa"
  resource_group_name       = azurerm_resource_group.tfstate.name
  location                  = azurerm_resource_group.tfstate.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  shared_access_key_enabled = true
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate-container"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "blob"
}
