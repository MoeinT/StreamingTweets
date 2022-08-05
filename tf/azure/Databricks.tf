resource "azurerm_databricks_workspace" "databricks-ws" {
  name                          = "db-streaming-ws-${var.env}"
  resource_group_name           = azurerm_resource_group.TerraformingAzureRg.name
  location                      = azurerm_resource_group.TerraformingAzureRg.location
  sku                           = "premium"
  public_network_access_enabled = true
}

#We need to reference an existing workspace in our Databricks provider
provider "databricks" {
  host = azurerm_databricks_workspace.databricks-ws.workspace_url
  #   token     = var.db_access_token
  auth_type = "pat"
}