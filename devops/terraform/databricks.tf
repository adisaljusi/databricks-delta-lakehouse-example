resource "azurerm_databricks_workspace" "lakehouse" {
  name                = "dbw${local.prefix}"
  resource_group_name = azurerm_resource_group.lakehouse.name
  location            = azurerm_resource_group.lakehouse.location
  sku                 = "premium"

  tags = {
    Environment = var.environment
  }
}

data "databricks_spark_version" "latest" {
  depends_on = [
    azurerm_databricks_workspace.lakehouse
  ]
}
data "databricks_node_type" "smallest" {
  local_disk = true

  depends_on = [
    azurerm_databricks_workspace.lakehouse
  ]
}

resource "databricks_cluster" "unity_sql" {
  cluster_name            = "Cluster"
  spark_version           = data.databricks_spark_version.latest.id
  node_type_id            = data.databricks_node_type.smallest.id
  autotermination_minutes = 10
  enable_elastic_disk     = false
  num_workers             = 2

  data_security_mode = "USER_ISOLATION"

  azure_attributes {
    availability = "SPOT"
  }
}

