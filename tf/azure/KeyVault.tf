resource "azurerm_key_vault" "KeyVault" {
  name                        = "KeyVault22-${var.env}"
  location                    = azurerm_resource_group.TerraformingAzureRg.location
  resource_group_name         = azurerm_resource_group.TerraformingAzureRg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7

  sku_name = "standard"


  dynamic "access_policy" {
    for_each = local.access_policy
    content {
      tenant_id           = access_policy.value.tenant_id
      object_id           = access_policy.value.object_id
      secret_permissions  = access_policy.value.secret_permissions
      key_permissions     = access_policy.value.key_permissions
      storage_permissions = access_policy.value.storage_permissions
    }
  }
}

#Add the service principal credentials into the key vault!
resource "azurerm_key_vault_secret" "KeyValutSecrets" {
  for_each     = local.key_vault_secrets
  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.KeyVault.id
}