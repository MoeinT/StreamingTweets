locals {
  access_policy = [
    {
      tenant_id           = data.azurerm_client_config.current.tenant_id,
      object_id           = azuread_service_principal.gh_actions.object_id,
      secret_permissions  = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
      key_permissions     = ["Get", ]
      storage_permissions = ["Get", ]
    },
    {
      tenant_id           = data.azurerm_client_config.current.tenant_id,
      object_id           = var.moein_obj_id,
      secret_permissions  = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
      key_permissions     = ["Get", ]
      storage_permissions = ["Get", ]
    },
    {
      tenant_id           = data.azurerm_client_config.current.tenant_id,
      object_id           = var.db_objid,
      secret_permissions  = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
      key_permissions     = ["Get", ]
      storage_permissions = ["Get", ]
    }
  ]

  key_vault_secrets = {
    "Client-id"                   = azuread_application.terraform-github.application_id,
    "App-object-id"               = azuread_application.terraform-github.object_id,
    "App-secret-id"               = azuread_application_password.Github-actions.key_id,
    "App-secret-value"            = azuread_application_password.Github-actions.value,
    "tenant-id"                   = data.azurerm_client_config.current.tenant_id
    "service-principal-object-id" = azuread_service_principal.gh_actions.object_id
    "sas-token-global"            = data.azurerm_storage_account_sas.StorageAccSasToken.sas
    "storageaccount"              = azurerm_storage_account.databricks-storageacc.name
    "sa-accountkey"               = azurerm_storage_account.databricks-storageacc.primary_access_key
    "Eventhub-ns-conn-str"        = azurerm_eventhub_namespace_authorization_rule.EventHubsNamespacePolicy.primary_connection_string
  }

}