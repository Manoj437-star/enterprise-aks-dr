variable "storage_account_name" {
  type        = string
  description = "Name of the storage account (lowercase alphanumeric, 3-24 chars)"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group for the storage account"
}

variable "location" {
  type        = string
  description = "Primary location"
}

variable "account_tier" {
  type        = string
  description = "Account Tier"
  default     = "Standard"
}

variable "account_replication_type" {
  type        = string
  description = "Replication type (GRS for cross-region disaster recovery, LRS for single-region dev)"
  default     = "GRS"
}

variable "container_name" {
  type        = string
  description = "Blob container name for backups"
  default     = "velero-backups"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}
