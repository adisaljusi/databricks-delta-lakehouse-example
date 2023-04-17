resource "azurerm_key_vault" "secrets" {
  name                          = "kv${local.prefix}"
  resource_group_name           = azurerm_resource_group.secrets.name
  location                      = azurerm_resource_group.secrets.location
  sku_name                      = var.keyvault_sku
  tenant_id                     = data.azurerm_client_config.service_connection.tenant_id
  purge_protection_enabled      = true
  enable_rbac_authorization     = true
  enabled_for_disk_encryption   = true
  soft_delete_retention_days    = 7
  public_network_access_enabled = true

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

resource "azurerm_key_vault_secret" "sp_client_secret" {
  name         = "ServicePrincipal--ClientSecret"
  value        = var.sp_client_secret
  key_vault_id = azurerm_key_vault.secrets.id

  depends_on = [
    azurerm_role_assignment.sp_kv
  ]
}

resource "azurerm_role_assignment" "azure_databricks" {
  scope                = azurerm_key_vault.secrets.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = "e6963077-bbff-4ae0-b707-5ef0d6322a49"
}

resource "databricks_secret_scope" "dbw_scope" {
  name = var.secret_scope_keyvault_name

  keyvault_metadata {
    resource_id = azurerm_key_vault.secrets.id
    dns_name    = azurerm_key_vault.secrets.vault_uri
  }
}
