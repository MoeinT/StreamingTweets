resource "azurerm_servicebus_namespace" "ServiceBusNameSpace" {
  name                = "moein-servicebus-namespace-${var.env}"
  location            = azurerm_resource_group.TerraformingAzureRg.location
  resource_group_name = azurerm_resource_group.TerraformingAzureRg.name
  sku                 = "Basic"
}