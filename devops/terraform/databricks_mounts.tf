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
