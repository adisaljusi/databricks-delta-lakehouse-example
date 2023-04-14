variable "environment" {
  type        = string
  description = "Short name for deployment environemnt (e.g., dev, uat, prd)"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the existing resource group where the Terraform state is stored"
}

variable "workload" {
  type        = string
  description = "Name for the workload specificed in the resource group (e.g., ingestion, ml, network)"
}

variable "region" {
  type        = string
  description = "Name of the region where the resources are targeted for deployment"
}
