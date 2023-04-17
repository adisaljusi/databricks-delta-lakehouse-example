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

resource "databricks_secret_scope" "dbw_scope" {
  name = var.secret_scope_keyvault_name

  keyvault_metadata {
    resource_id = azurerm_key_vault.secrets.id
    dns_name    = azurerm_key_vault.secrets.vault_uri
  }
}

