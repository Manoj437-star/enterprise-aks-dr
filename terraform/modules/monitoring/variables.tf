variable "workspace_name" {
  type        = string
  description = "Name of Log Analytics workspace"
  default     = "law-aks-dr-poc"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group for monitoring"
}

variable "location" {
  type        = string
  description = "Azure location"
}

variable "alert_email" {
  type        = string
  description = "Notification email for alerts"
  default     = "manojdeep.jaiswal@gmail.com"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}
