variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the existing resource group where the Terraform state is stored"
}

variable "environment" {
  type = string
  description = "Short name for deployment environemnt (e.g., dev, uat, prd)"
}

