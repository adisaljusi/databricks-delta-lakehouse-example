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
  azure_workspace_resource_id = azurerm_databricks_workspace.lakehouse.id
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
