resource "azurerm_traffic_manager_profile" "profile" {
  name                   = var.profile_name
  resource_group_name    = var.resource_group_name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = var.dns_relative_name
    ttl           = 30
  }

  monitor_config {
    protocol                     = "HTTP"
    port                         = 80
    path                         = "/healthz"
    interval_in_seconds          = 10
    timeout_in_seconds           = 5
    tolerated_number_of_failures = 3
  }

  tags = var.tags
}

resource "azurerm_traffic_manager_external_endpoint" "primary" {
  name                 = "ep-primary-eastus2"
  profile_id           = azurerm_traffic_manager_profile.profile.id
  target               = var.primary_target_host
  enabled              = true
  priority             = 1
  always_serve_enabled = false
}

resource "azurerm_traffic_manager_external_endpoint" "secondary" {
  name                 = "ep-secondary-westus3"
  profile_id           = azurerm_traffic_manager_profile.profile.id
  target               = var.secondary_target_host
  enabled              = true
  priority             = 2
  always_serve_enabled = false
}
