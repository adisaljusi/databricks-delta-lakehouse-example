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

}

data "azurerm_resource_group" "infrastructure" {
  name = var.resource_group_name
}
