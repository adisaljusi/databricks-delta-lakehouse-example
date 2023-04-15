resource "azurerm_key_vault" "secrets" {
  name                        = "kv${local.prefix}"
  resource_group_name         = azurerm_resource_group.secrets.name
  location                    = azurerm_resource_group.secrets.location
  sku_name                    = var.keyvault_sku
  tenant_id                   = data.azurerm_client_config.service_connection.tenant_id
  purge_protection_enabled    = true
  enable_rbac_authorization   = true
  enabled_for_disk_encryption = true
  soft_delete_retention_days  = 7

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_role_assignment" "sp_kv" {
  scope                = azurerm_key_vault.secrets.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.service_connection.object_id
}

resource "databricks_secret_scope" "dbw_scope" {
  name = "keyvault"

  keyvault_metadata {
    resource_id = azurerm_key_vault.secrets.id
    dns_name    = azurerm_key_vault.secrets.vault_uri
  }
}
