variable "profile_name" {
  type        = string
  description = "Traffic Manager profile name"
  default     = "tm-dr-global"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group for Traffic Manager"
}

variable "dns_relative_name" {
  type        = string
  description = "DNS relative name for trafficmanager.net"
  default     = "ecommerce-dr-global"
}

variable "primary_target_host" {
  type        = string
  description = "FQDN or IP of primary ingress"
}

variable "secondary_target_host" {
  type        = string
  description = "FQDN or IP of secondary ingress"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}
