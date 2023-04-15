terraform {
  backend "azurerm" {
    snapshot = true
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.52.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "1.14.3"
    }
  }
}

provider "azurerm" {
  features {}
  environment = "public"
}

provider "databricks" {
  host                        = azurerm_databricks_workspace.lakehouse.workspace_url
  azure_workspace_resource_id = azurerm_databricks_workspace.lakehouse.id
  azure_use_msi               = true
}

data "azurerm_resource_group" "infrastructure" {
  name = var.resource_group_name
}

data "azurerm_client_config" "service_connection" {}

resource "azurerm_resource_group" "lakehouse" {
  name     = "rg-${local.prefix}"
  location = data.azurerm_resource_group.infrastructure.location

  tags = {
    "environment" = var.environment
  }
}
