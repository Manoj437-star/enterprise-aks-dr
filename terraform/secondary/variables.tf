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
  description = "VM SKU for the worker nodes"
  default     = "Standard_B2s"
}

variable "node_count" {
  type        = number
  description = "Secondary cluster worker node count (Warm Standby)"
  default     = 1
}

variable "acr_id" {
  type        = string
  description = "Resource ID of the shared ACR (from primary region outputs)"
  default     = null
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics workspace ID for monitoring"
  default     = null
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
