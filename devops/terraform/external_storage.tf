resource "azurerm_databricks_access_connector" "external_access_connector" {
  name                = "ext-ac-mi"
  resource_group_name = azurerm_resource_group.lakehouse.name
  location            = azurerm_resource_group.lakehouse.location

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_storage_account" "ext_adls" {
  name                     = "saextlake${local.prefix_clean}"
  resource_group_name      = azurerm_resource_group.lakehouse.name
  location                 = azurerm_resource_group.lakehouse.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  is_hns_enabled           = true

  enable_https_traffic_only       = true
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

resource "azurerm_storage_container" "ext_storage" {
  name                  = "raw"
  storage_account_name  = azurerm_storage_account.ext_adls.name
  container_access_type = "private"
}

resource "azurerm_role_assignment" "sp_sa_adls" {
  scope                = azurerm_storage_account.ext_adls.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = data.azurerm_client_config.service_connection.object_id

  depends_on = [
    azurerm_storage_account.ext_adls
  ]
}


resource "azurerm_role_assignment" "sp_ext_storage" {
  scope                = azurerm_storage_account.ext_adls.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_access_connector.external_access_connector.identity[0].principal_id

  depends_on = [
    azurerm_storage_account.ext_adls
  ]
}

resource "databricks_storage_credential" "external" {
  name    = azurerm_databricks_access_connector.external_access_connector.name
  comment = "Managed by TF"

  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.external_access_connector.id
  }

  depends_on = [
    databricks_metastore_assignment.primary
  ]
}

resource "databricks_external_location" "some" {
  name = "external"
  url = format("abfss://%s@%s.dfs.core.windows.net",
    azurerm_storage_container.ext_storage.name,
  azurerm_storage_account.ext_adls.name)

  credential_name = databricks_storage_credential.external.id
  comment         = "Managed by TF"

  depends_on = [
    databricks_metastore_assignment.primary,
    azurerm_role_assignment.sp_ext_storage
  ]
}

resource "databricks_grants" "some" {
  external_location = databricks_external_location.some.id

  grant {
    principal  = "Data Engineers"
    privileges = ["ALL_PRIVILEGES"]
  }
}
