output "resource_group_name" {
  description = "Primary Resource Group"
  value       = azurerm_resource_group.primary.name
}

output "aks_cluster_name" {
  description = "Primary AKS Cluster Name"
  value       = module.aks.cluster_name
}

output "acr_login_server" {
  description = "ACR Login Server FQDN"
  value       = module.acr.login_server
}

output "acr_id" {
  description = "ACR ID"
  value       = module.acr.acr_id
}

output "storage_account_name" {
  description = "Velero Storage Account Name"
  value       = module.storage.storage_account_name
}

output "storage_container_name" {
  description = "Velero Storage Container Name"
  value       = module.storage.container_name
}

output "primary_ingress_ip" {
  description = "Primary Ingress Static Public IP"
  value       = azurerm_public_ip.primary_ingress_ip.ip_address
}

output "primary_ingress_fqdn" {
  description = "Primary Ingress FQDN"
  value       = azurerm_public_ip.primary_ingress_ip.fqdn
}

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  value       = module.monitoring.workspace_id
}
