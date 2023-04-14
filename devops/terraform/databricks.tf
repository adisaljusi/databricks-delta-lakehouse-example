resource "azurerm_databricks_workspace" "lakehouse" {
  name                = "dbw${local.prefix}"
  resource_group_name = azurerm_resource_group.lakehouse.name
  location            = azurerm_resource_group.lakehouse.location
  sku                 = "premium"

  tags = {
    Environment = var.environment
  }
}


