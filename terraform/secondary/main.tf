resource "azurerm_resource_group" "secondary" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "networking" {
  source              = "../modules/networking"
  resource_group_name = azurerm_resource_group.secondary.name
  location            = azurerm_resource_group.secondary.location
  vnet_name           = var.vnet_name
  address_space       = ["10.241.0.0/16"]
  aks_subnet_cidr     = "10.241.1.0/24"
  ingress_subnet_cidr = "10.241.2.0/24"
  tags                = var.tags
}

resource "azurerm_public_ip" "secondary_ingress_ip" {
  name                = "pip-ingress-secondary-westus3"
  location            = azurerm_resource_group.secondary.location
  resource_group_name = azurerm_resource_group.secondary.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "ecommerce-ingress-secondary-${substr(md5(azurerm_resource_group.secondary.id), 0, 6)}"
  tags                = var.tags
}

module "aks" {
  source                     = "../modules/aks"
  cluster_name               = var.cluster_name
  resource_group_name        = azurerm_resource_group.secondary.name
  location                   = azurerm_resource_group.secondary.location
  dns_prefix                 = "aks-dr-sec"
  node_count                 = var.node_count
  vm_size                    = var.vm_size
  vnet_subnet_id             = module.networking.aks_subnet_id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  acr_id                     = var.acr_id
  tags                       = var.tags
}
