variable "resource_group_name" {
  type        = string
  description = "Name of Primary Resource Group"
  default     = "rg-dr-primary-eastus2"
}

variable "location" {
  type        = string
  description = "Primary Azure region"
  default     = "eastus2"
}

variable "vnet_name" {
  type        = string
  description = "Primary VNet name"
  default     = "vnet-dr-primary-eastus2"
}

variable "cluster_name" {
  type        = string
  description = "Primary AKS cluster name"
  default     = "aks-dr-primary-eastus2"
}

variable "vm_size" {
  type        = string
  description = "VM SKU for the worker nodes"
  default     = "Standard_D2s_v6"
}

variable "node_count" {
  type        = number
  description = "Primary cluster worker node count"
  default     = 1
}

variable "acr_name" {
  type        = string
  description = "Globally unique ACR name"
  default     = "acrdreastus2poc"
}

variable "acr_sku" {
  type        = string
  description = "ACR SKU (Standard for POC cost efficiency, Premium for native geo-rep)"
  default     = "Standard"
}

variable "storage_account_name" {
  type        = string
  description = "Storage account for Velero backups (must be globally unique, 3-24 chars lowercase alphanumeric)"
  default     = "stdreastus2backup"
}

variable "alert_email" {
  type        = string
  description = "Alert notification recipient email"
  default     = "manojdeep.jaiswal@gmail.com"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default = {
    Environment = "POC"
    Project     = "AKS-MultiRegion-DR"
    Region      = "Primary-EastUS2"
    ManagedBy   = "Terraform"
  }
}
