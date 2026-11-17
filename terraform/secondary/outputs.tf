output "resource_group_name" {
  description = "Secondary Resource Group"
  value       = azurerm_resource_group.secondary.name
}

output "aks_cluster_name" {
  description = "Secondary AKS Cluster Name"
  value       = module.aks.cluster_name
}

output "secondary_ingress_ip" {
  description = "Secondary Ingress Static Public IP"
  value       = azurerm_public_ip.secondary_ingress_ip.ip_address
}

output "secondary_ingress_fqdn" {
  description = "Secondary Ingress FQDN"
  value       = azurerm_public_ip.secondary_ingress_ip.fqdn
}

output "log_analytics_workspace_id" {
  description = "Secondary Log Analytics Workspace ID"
  value       = module.monitoring.workspace_id
}
