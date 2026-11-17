output "frontdoor_endpoint_fqdn" {
  description = "Global Front Door Endpoint FQDN"
  value       = module.frontdoor.frontdoor_endpoint_fqdn
}

output "traffic_manager_fqdn" {
  description = "Global Traffic Manager FQDN"
  value       = module.traffic_manager.traffic_manager_fqdn
}
