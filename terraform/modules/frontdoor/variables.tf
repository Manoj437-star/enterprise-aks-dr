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
  default     = "Premium_AzureFrontDoor"
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

variable "enable_waf" {
  type        = bool
  description = "Whether to create and attach a WAF policy"
  default     = true
}

variable "waf_policy_name" {
  type        = string
  description = "Name of the Front Door WAF policy (alphanumeric only)"
  default     = "wafglobaldr"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}
