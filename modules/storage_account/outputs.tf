output "primary_access_key" {
  value       = azurerm_storage_account.main.primary_access_key
  description = "The primary access key of the storage account"
}

output "name" {
  value       = azurerm_storage_account.main.name
  description = "The storage account name"
}
