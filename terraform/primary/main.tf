resource "azurerm_resource_group" "primary" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "networking" {
  source              = "../modules/networking"
  resource_group_name = azurerm_resource_group.primary.name
  location            = azurerm_resource_group.primary.location
  vnet_name           = var.vnet_name
  address_space       = ["10.240.0.0/16"]
  aks_subnet_cidr     = "10.240.1.0/24"
  ingress_subnet_cidr = "10.240.2.0/24"
  tags                = var.tags
}

module "monitoring" {
  source              = "../modules/monitoring"
  workspace_name      = "law-aks-dr-primary"
  resource_group_name = azurerm_resource_group.primary.name
  location            = azurerm_resource_group.primary.location
  alert_email         = var.alert_email
  tags                = var.tags
}

module "storage" {
  source                   = "../modules/storage"
  storage_account_name     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.primary.name
  location                 = azurerm_resource_group.primary.location
  account_replication_type = "GRS"
  container_name           = "velero-backups"
  tags                     = var.tags
}

module "acr" {
  source              = "../modules/acr"
  registry_name       = var.acr_name
  resource_group_name = azurerm_resource_group.primary.name
  location            = azurerm_resource_group.primary.location
  sku                 = var.acr_sku
  tags                = var.tags
}

resource "azurerm_public_ip" "primary_ingress_ip" {
  name                = "pip-ingress-primary-eastus2"
  location            = azurerm_resource_group.primary.location
  resource_group_name = azurerm_resource_group.primary.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "ecommerce-ingress-primary-eastus2"
  tags                = var.tags
}

module "aks" {
  source                     = "../modules/aks"
  cluster_name               = var.cluster_name
  resource_group_name        = azurerm_resource_group.primary.name
  location                   = azurerm_resource_group.primary.location
  dns_prefix                 = "aks-dr-pri"
  node_count                 = var.node_count
  vm_size                    = var.vm_size
  vnet_subnet_id             = module.networking.aks_subnet_id
  log_analytics_workspace_id = module.monitoring.workspace_id
  attach_acr                 = true
  acr_id                     = module.acr.acr_id
  tags                       = var.tags
}
