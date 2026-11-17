variable "cluster_name" {
  type        = string
  description = "Name of the AKS cluster"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group where AKS will reside"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "dns_prefix" {
  type        = string
  description = "DNS prefix for the AKS cluster"
  default     = "aksdr"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version"
  default     = "1.31"
}

variable "node_count" {
  type        = number
  description = "Initial number of worker nodes"
  default     = 1
}

variable "vm_size" {
  type        = string
  description = "VM SKU for the worker nodes (kept at Standard_B2s for quota & cost control)"
  default     = "Standard_B2s"
}

variable "vnet_subnet_id" {
  type        = string
  description = "Subnet ID for AKS node and pod IP allocation"
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Optional Log Analytics workspace ID for Container Insights"
  default     = null
}

variable "attach_acr" {
  type        = bool
  description = "Whether to attach ACR role assignment"
  default     = false
}

variable "acr_id" {
  type        = string
  description = "Optional ACR ID to grant AcrPull role to AKS Kubelet Identity"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}
