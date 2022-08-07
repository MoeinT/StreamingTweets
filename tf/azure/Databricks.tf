resource "azurerm_databricks_workspace" "databricks-ws" {
  name                          = "db-streaming-ws-${var.env}"
  resource_group_name           = azurerm_resource_group.TerraformingAzureRg.name
  location                      = azurerm_resource_group.TerraformingAzureRg.location
  managed_resource_group_name   = "db-managed-rg-${var.env}"
  sku                           = "premium"
  public_network_access_enabled = true
}

#We need to reference an existing workspace in our Databricks provider
provider "databricks" {
  host                        = azurerm_databricks_workspace.databricks-ws.workspace_url
  azure_workspace_resource_id = azurerm_databricks_workspace.databricks-ws.id
  azure_client_id             = azuread_application.terraform-github.application_id
  azure_client_secret         = azuread_application_password.Github-actions.value
  azure_tenant_id             = data.azurerm_client_config.current.tenant_id
}

resource "databricks_cluster" "SingleNodeCluster" {
  cluster_name            = "db-sn-cluster-${var.env}"
  spark_version           = "7.3.x-scala2.12"
  node_type_id            = "Standard_DS3_v2"
  autotermination_minutes = 20
  num_workers             = 0

  spark_conf = {
    "spark.databricks.cluster.profile" : "singleNode"
    "spark.master" : "local[*]"
  }

  custom_tags = {
    "ResourceClass" = "SingleNode"
  }
}

# #Install the maven library for Azure EventHub
# resource "databricks_library" "maven-EventHub" {
#   cluster_id = databricks_cluster.SingleNodeCluster.id
#   maven {
#     coordinates = "com.microsoft.azure:azure-eventhubs-spark_2.12:2.3.22"
#   }
# }