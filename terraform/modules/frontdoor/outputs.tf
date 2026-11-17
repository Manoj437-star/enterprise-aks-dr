output "frontdoor_profile_id" {
  description = "Front Door Profile ID"
  value       = azurerm_cdn_frontdoor_profile.profile.id
}

output "frontdoor_endpoint_id" {
  description = "Front Door Endpoint ID"
  value       = azurerm_cdn_frontdoor_endpoint.endpoint.id
}

output "frontdoor_endpoint_fqdn" {
  description = "Front Door Endpoint Hostname"
  value       = azurerm_cdn_frontdoor_endpoint.endpoint.host_name
}
