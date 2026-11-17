provider "azurerm" {
  subscription_id = "634797e9-e825-4199-b9c1-40fc24dc3400"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
