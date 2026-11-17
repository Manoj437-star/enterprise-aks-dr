output "storage_account_id" {
  description = "Storage Account ID"
  value       = azurerm_storage_account.sa.id
}

output "storage_account_name" {
  description = "Storage Account Name"
  value       = azurerm_storage_account.sa.name
}

output "container_name" {
  description = "Blob Container Name"
  value       = azurerm_storage_container.container.name
}

output "primary_blob_endpoint" {
  description = "Primary Blob Endpoint"
  value       = azurerm_storage_account.sa.primary_blob_endpoint
}

output "primary_access_key" {
  description = "Primary Storage Account Key"
  value       = azurerm_storage_account.sa.primary_access_key
  sensitive   = true
}
