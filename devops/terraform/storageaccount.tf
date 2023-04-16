resource "azurerm_storage_account" "adls" {
  name                     = "sa${local.prefix_clean}"
  resource_group_name      = azurerm_resource_group.lakehouse.name
  location                 = azurerm_resource_group.lakehouse.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  is_hns_enabled           = true

  enable_https_traffic_only = true
  /*
    For the creation of storage account container, `public_network_acces_enabled` needs to be set to true (defaults to true).
    Otherwise the Terraform plan cannot be applied successfully, if the agent is not in the same network. 
    A workaround/viable solution is to temporarily enable public network access. After the plan command was applied, the storage account network settings to be reverted. 
    j
    # public_network_access_enabled   = false
  */
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_storage_container" "unity_catalog" {
  name                  = "unitycatalog"
  storage_account_name  = azurerm_storage_account.adls.name
  container_access_type = "private"

  depends_on = [
    azurerm_storage_account.adls
  ]
}

resource "azurerm_role_assignment" "sp_sa_ext_adls" {
  scope                = azurerm_storage_account.adls.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = data.azurerm_client_config.service_connection.object_id

  depends_on = [
    azurerm_storage_account.adls
  ]
}

resource "azurerm_role_assignment" "mi_unity_catalog" {
  scope                = azurerm_storage_account.adls.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_access_connector.unity.identity[0].principal_id
}
