output "vnet_id" {
  description = "Virtual Network ID"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "Virtual Network Name"
  value       = azurerm_virtual_network.vnet.name
}

output "aks_subnet_id" {
  description = "AKS Subnet ID"
  value       = azurerm_subnet.aks_subnet.id
}

output "ingress_subnet_id" {
  description = "Ingress Subnet ID"
  value       = azurerm_subnet.ingress_subnet.id
}
