resource "azurerm_databricks_access_connector" "unity" {
  name                = "db-mi-${local.prefix}"
  resource_group_name = azurerm_resource_group.lakehouse.name
  location            = azurerm_resource_group.lakehouse.location

  identity {
    type = "SystemAssigned"
  }
}

resource "databricks_metastore" "primary" {
  name = "primary"
  storage_root = format("abfss://%s@%s.dfs.core.windows.net/",
    azurerm_storage_container.unity_catalog.name,
  azurerm_storage_account.adls.name)
  force_destroy = true
}

resource "databricks_metastore_data_access" "primary" {
  metastore_id = databricks_metastore.primary.id
  name         = "mi_dac"

  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.unity.id
  }

  is_default = true
}

resource "databricks_metastore_assignment" "primary" {
  metastore_id         = databricks_metastore.primary.id
  workspace_id         = azurerm_databricks_workspace.lakehouse.workspace_id
  default_catalog_name = "hive_metastore"
}

