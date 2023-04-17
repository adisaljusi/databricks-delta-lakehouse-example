resource "azurerm_databricks_workspace" "lakehouse" {
  name                        = "dbw${local.prefix}"
  resource_group_name         = azurerm_resource_group.lakehouse.name
  location                    = azurerm_resource_group.lakehouse.location
  sku                         = "premium"
  managed_resource_group_name = "rg-dbw-${local.prefix}"

  tags = {
    Environment = var.environment
  }
}

data "databricks_spark_version" "latest" {
  depends_on = [
    azurerm_databricks_workspace.lakehouse
  ]
}


resource "databricks_cluster" "unity_sql" {
  cluster_name            = "Cluster"
  spark_version           = data.databricks_spark_version.latest.id
  node_type_id            = "Standard_DS3_v2"
  driver_node_type_id     = "Standard_DS3_v2"
  runtime_engine          = "PHOTON"
  autotermination_minutes = 10
  enable_elastic_disk     = false
  num_workers             = 2

  data_security_mode = "NONE"

  azure_attributes {
    availability = "SPOT"
  }

  depends_on = [
    databricks_metastore_assignment.primary
  ]
}


resource "databricks_mount" "raw" {
  name       = "raw"
  uri        = "abfss://${azurerm_storage_container.ext_storage.name}@${azurerm_storage_account.ext_adls.name}.dfs.core.windows.net"
  cluster_id = databricks_cluster.unity_sql.id

  extra_configs = {
    "fs.azure.account.auth.type" : "OAuth",
    "fs.azure.account.oauth.provider.type" : "org.apache.hadoop.fs.azurebfs.oauth2.ClientCredsTokenProvider",
    "fs.azure.account.oauth2.client.id" : data.azurerm_client_config.service_connection.client_id,
    "fs.azure.account.oauth2.client.secret" : "{{secrets/${var.secret_scope_keyvault_name}/${azurerm_key_vault_secret.sp_client_secret.name}}}",
    "fs.azure.account.oauth2.client.endpoint" : "https://login.microsoftonline.com/${data.azurerm_client_config.service_connection.tenant_id}/oauth2/token",
    "fs.azure.createRemoteFileSystemDuringInitialization" : "false",
  }

  depends_on = [
    azurerm_role_assignment.azure_databricks
  ]
}
