output "acr_id" {
  description = "ACR Resource ID"
  value       = azurerm_container_registry.acr.id
}

output "login_server" {
  description = "ACR Login Server FQDN"
  value       = azurerm_container_registry.acr.login_server
}

output "registry_name" {
  description = "ACR Name"
  value       = azurerm_container_registry.acr.name
}
