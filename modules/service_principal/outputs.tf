
output "service_principal_application_id" {
  value       = azuread_application.main.application_id
  description = "Service Principal Application ID"
}

output "service_principal_object_id" {
  value       = azuread_service_principal.main.id
  description = "Service Principal Object ID"
}

output "service_principal_secret" {
  value       = azuread_service_principal_password.pwd.value
  description = "Service Principal Secret"
}
