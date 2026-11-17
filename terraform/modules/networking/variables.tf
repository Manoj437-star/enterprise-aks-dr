variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "vnet_name" {
  type        = string
  description = "Virtual Network name"
}

variable "address_space" {
  type        = list(string)
  description = "Address space for the VNet"
  default     = ["10.240.0.0/16"]
}

variable "aks_subnet_cidr" {
  type        = string
  description = "CIDR block for the AKS subnet"
  default     = "10.240.1.0/24"
}

variable "ingress_subnet_cidr" {
  type        = string
  description = "CIDR block for the Ingress subnet"
  default     = "10.240.2.0/24"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}
