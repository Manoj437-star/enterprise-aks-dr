resource "azurerm_resource_group" "global" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "frontdoor" {
  source                = "../modules/frontdoor"
  frontdoor_name        = "afd-ecommerce-dr-global"
  resource_group_name   = azurerm_resource_group.global.name
  sku_name              = var.frontdoor_sku
  endpoint_name         = "ep-dr-ecom-634797"
  primary_origin_host   = var.primary_ingress_host
  secondary_origin_host = var.secondary_ingress_host
  enable_waf            = true
  waf_policy_name       = "wafglobaldr"
  tags                  = var.tags
}
