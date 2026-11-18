output "resource_group_name" {
  description = "Global Traffic Management Resource Group"
  value       = azurerm_resource_group.global.name
}

output "frontdoor_profile_id" {
  description = "Front Door Profile ID"
  value       = module.frontdoor.frontdoor_profile_id
}

output "frontdoor_endpoint_fqdn" {
  description = "Front Door Global Endpoint FQDN"
  value       = module.frontdoor.frontdoor_endpoint_fqdn
}
