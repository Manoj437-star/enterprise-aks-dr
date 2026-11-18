resource "azurerm_cdn_frontdoor_profile" "profile" {
  name                = var.frontdoor_name
  resource_group_name = var.resource_group_name
  sku_name            = var.sku_name
  tags                = var.tags
}

resource "azurerm_cdn_frontdoor_endpoint" "endpoint" {
  name                     = var.endpoint_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.profile.id
  tags                     = var.tags
}

resource "azurerm_cdn_frontdoor_origin_group" "origin_group" {
  name                     = "og-ecommerce"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.profile.id

  health_probe {
    interval_in_seconds = 10
    path                = "/healthz"
    protocol            = "Http"
    request_type        = "GET"
  }

  load_balancing {
    additional_latency_in_milliseconds = 50
    sample_size                        = 4
    successful_samples_required        = 3
  }
}

resource "azurerm_cdn_frontdoor_origin" "primary" {
  name                          = "origin-primary-eastus2"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.origin_group.id
  enabled                       = true

  certificate_name_check_enabled = false
  host_name                      = var.primary_origin_host
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = var.primary_origin_host
  priority                       = 1
  weight                         = 100
}

resource "azurerm_cdn_frontdoor_origin" "secondary" {
  name                          = "origin-secondary-westus3"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.origin_group.id
  enabled                       = true

  certificate_name_check_enabled = false
  host_name                      = var.secondary_origin_host
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = var.secondary_origin_host
  priority                       = 2
  weight                         = 100
}

resource "azurerm_cdn_frontdoor_route" "route" {
  name                          = "route-ecommerce"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.origin_group.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.primary.id, azurerm_cdn_frontdoor_origin.secondary.id]

  supported_protocols    = ["Http", "Https"]
  patterns_to_match      = ["/*"]
  forwarding_protocol    = "HttpOnly"
  https_redirect_enabled = false
  link_to_default_domain = true
}

resource "azurerm_cdn_frontdoor_firewall_policy" "waf" {
  count                             = var.enable_waf ? 1 : 0
  name                              = var.waf_policy_name
  resource_group_name               = var.resource_group_name
  sku_name                          = var.sku_name
  enabled                           = true
  mode                              = "Prevention"
  custom_block_response_status_code = 403
  custom_block_response_body        = base64encode("Blocked by Global AKS DR WAF Policy")

  managed_rule {
    type    = "Microsoft_DefaultRuleSet"
    version = "2.1"
    action  = "Block"
  }

  tags = var.tags
}

resource "azurerm_cdn_frontdoor_security_policy" "security_policy" {
  count                    = var.enable_waf ? 1 : 0
  name                     = "sec-policy-global"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.profile.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.waf[0].id

      association {
        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_endpoint.endpoint.id
        }
        patterns_to_match = ["/*"]
      }
    }
  }
}
