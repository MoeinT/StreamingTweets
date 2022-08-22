
resource "azurerm_eventhub_namespace" "TaxiSourceEventHubsNamespace" {
  name                = "EventHub-ns-${var.env}"
  location            = azurerm_resource_group.TerraformingAzureRg.location
  resource_group_name = azurerm_resource_group.TerraformingAzureRg.name
  sku                 = "Basic"
  capacity            = 1
}

#All the Eventhubs
resource "azurerm_eventhub" "AllEventHubs" {
  for_each            = toset(["RideStartEventhub-${var.env}", "RideEndEventhub-${var.env}", "AnamoliesEventHubs-${var.env}", "StockDataEventHubs-${var.env}"])
  name                = each.key
  namespace_name      = azurerm_eventhub_namespace.TaxiSourceEventHubsNamespace.name
  resource_group_name = azurerm_resource_group.TerraformingAzureRg.name
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_eventhub_namespace_authorization_rule" "EventHubsNamespacePolicy" {
  name                = "RootManageSharedAccessKey"
  namespace_name      = azurerm_eventhub_namespace.TaxiSourceEventHubsNamespace.name
  resource_group_name = azurerm_resource_group.TerraformingAzureRg.name

  listen = true
  send   = true
  manage = true
}