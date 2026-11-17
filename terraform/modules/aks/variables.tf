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
  description = "Kubernetes version (using standard GA version 1.36)"
  default     = "1.36"
}

variable "node_count" {
  type        = number
  description = "Initial number of worker nodes"
  default     = 1
}

variable "vm_size" {
  type        = string
  description = "VM SKU for the worker nodes (Standard_D2s_v6: 2 vCPUs, 8GB RAM, supported by AKS in East US 2)"
  default     = "Standard_D2s_v6"
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
