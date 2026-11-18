variable "resource_group_name" {
  type        = string
  description = "Resource Group for Global Traffic Management"
  default     = "rg-dr-global-traffic"
}

variable "location" {
  type        = string
  description = "Resource Group location"
  default     = "eastus2"
}

variable "frontdoor_sku" {
  type        = string
  description = "SKU for Front Door: Standard_AzureFrontDoor or Premium_AzureFrontDoor"
  default     = "Premium_AzureFrontDoor"
}

variable "primary_ingress_host" {
  type        = string
  description = "FQDN of East US 2 Application Load Balancer"
  default     = "ecommerce-dr-primary-eastus2.eastus2.cloudapp.azure.com"
}

variable "secondary_ingress_host" {
  type        = string
  description = "FQDN of West US 3 Application Load Balancer"
  default     = "ecommerce-dr-secondary-westus3.westus3.cloudapp.azure.com"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default = {
    Environment = "POC"
    Project     = "AKS-MultiRegion-DR"
    Component   = "GlobalTrafficManagement"
    ManagedBy   = "Terraform"
  }
}
