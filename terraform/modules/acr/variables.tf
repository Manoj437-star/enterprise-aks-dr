variable "registry_name" {
  type        = string
  description = "Unique name for the Azure Container Registry (alphanumeric only)"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group for ACR"
}

variable "location" {
  type        = string
  description = "Primary location for ACR"
}

variable "sku" {
  type        = string
  description = "SKU for ACR (Standard for budget testing, Premium for native geo-replication)"
  default     = "Standard"
}

variable "georeplications" {
  type = list(object({
    location                = string
    zone_redundancy_enabled = optional(bool)
    tags                    = optional(map(string))
  }))
  description = "Geo-replication locations (valid only when sku is Premium)"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}
