variable "frontdoor_name" {
  type        = string
  description = "Front Door profile name"
  default     = "afd-dr-global"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "sku_name" {
  type        = string
  description = "SKU for Front Door: Standard_AzureFrontDoor or Premium_AzureFrontDoor"
  default     = "Standard_AzureFrontDoor"
}

variable "endpoint_name" {
  type        = string
  description = "Front Door endpoint name"
  default     = "ep-ecommerce-dr"
}

variable "primary_origin_host" {
  type        = string
  description = "FQDN or Public IP of the Primary Region Ingress Controller"
}

variable "secondary_origin_host" {
  type        = string
  description = "FQDN or Public IP of the Secondary Region Ingress Controller"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}
