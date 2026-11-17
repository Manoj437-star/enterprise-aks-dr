output "traffic_manager_profile_id" {
  description = "Traffic Manager Profile ID"
  value       = azurerm_traffic_manager_profile.profile.id
}

output "traffic_manager_fqdn" {
  description = "Traffic Manager Fully Qualified Domain Name"
  value       = azurerm_traffic_manager_profile.profile.fqdn
}
