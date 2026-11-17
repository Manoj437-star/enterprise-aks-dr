resource "azurerm_resource_group" "global" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "frontdoor" {
  source                = "../../modules/frontdoor"
  frontdoor_name        = "afd-ecommerce-dr-global"
  resource_group_name   = azurerm_resource_group.global.name
  sku_name              = var.frontdoor_sku
  endpoint_name         = "ep-ecommerce-dr-global"
  primary_origin_host   = var.primary_ingress_host
  secondary_origin_host = var.secondary_ingress_host
  tags                  = var.tags
}

module "traffic_manager" {
  source                = "../../modules/traffic-manager"
  profile_name          = "tm-ecommerce-dr-global"
  resource_group_name   = azurerm_resource_group.global.name
  dns_relative_name     = "ecommerce-dr-${substr(md5(azurerm_resource_group.global.id), 0, 6)}"
  primary_target_host   = var.primary_ingress_host
  secondary_target_host = var.secondary_ingress_host
  tags                  = var.tags
}
