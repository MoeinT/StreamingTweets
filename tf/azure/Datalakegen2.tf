resource "azurerm_storage_account" "databricks-storageacc" {
  name                     = "eventhubs22sa22${var.env}"
  resource_group_name      = azurerm_resource_group.TerraformingAzureRg.name
  location                 = azurerm_resource_group.TerraformingAzureRg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = "true"
}

# resource "azurerm_storage_data_lake_gen2_filesystem" "TaxiRides" {
#   name               = "taxirides"
#   storage_account_id = azurerm_storage_account.databricks-storageacc.id
# }

# resource "azurerm_storage_data_lake_gen2_filesystem" "StockMarket" {
#   name               = "stockmarket"
#   storage_account_id = azurerm_storage_account.databricks-storageacc.id
# }

# #A global sas token for the above sa
# data "azurerm_storage_account_sas" "databricks-tutorials-globaltoken" {
#   connection_string = azurerm_storage_account.databricks-tutorials-sa.primary_connection_string
#   https_only        = true

#   resource_types {
#     service   = true
#     container = true
#     object    = true
#   }

#   services {
#     blob  = true
#     queue = true
#     table = true
#     file  = true
#   }

#   start  = "2022-07-24T16:20:00Z"
#   expiry = "2022-08-24T16:20:00Z"

#   permissions {
#     read    = true
#     write   = true
#     delete  = false
#     list    = true
#     add     = true
#     create  = false
#     update  = true
#     process = false
#     tag     = false
#     filter  = false
#   }
# }