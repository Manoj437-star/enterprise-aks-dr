variable "resource_group_name" {
  type        = string
  description = "Name of Secondary Resource Group"
  default     = "rg-dr-secondary-westus3"
}

variable "location" {
  type        = string
  description = "Secondary Azure region"
  default     = "westus3"
}

variable "vnet_name" {
  type        = string
  description = "Secondary VNet name"
  default     = "vnet-dr-secondary-westus3"
}

variable "cluster_name" {
  type        = string
  description = "Secondary AKS cluster name"
  default     = "aks-dr-secondary-westus3"
}

variable "vm_size" {
  type        = string
  description = "VM SKU for the worker nodes (Standard_D2s_v4 selected due to West US 3 regional availability)"
  default     = "Standard_D2s_v4"
}

variable "node_count" {
  type        = number
  description = "Secondary cluster worker node count (Warm Standby)"
  default     = 1
}

variable "acr_id" {
  type        = string
  description = "Resource ID of the shared ACR (from primary region outputs)"
  default     = "/subscriptions/634797e9-e825-4199-b9c1-40fc24dc3400/resourceGroups/rg-dr-primary-eastus2/providers/Microsoft.ContainerRegistry/registries/acrdreastus2poc"
}

variable "alert_email" {
  type        = string
  description = "Email address for Azure Monitor alert notifications"
  default     = "manojdeep.jaiswal@gmail.com"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default = {
    Environment = "POC"
    Project     = "AKS-MultiRegion-DR"
    Region      = "Secondary-WestUS3"
    ManagedBy   = "Terraform"
  }
}
