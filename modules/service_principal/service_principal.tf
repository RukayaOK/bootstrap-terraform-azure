# CREATE SERVICE PRINCIPAL
resource "azuread_application" "main" {
  display_name = var.service_principal_name
  owners       = var.service_principal_owners

  # dynamic "api" {
  #   for
  #   content {
  #     requested_access_token_version = 2
  #   } 
  # }
}

resource "azuread_service_principal" "main" {
  application_id               = azuread_application.main.application_id
  app_role_assignment_required = false
  owners                       = var.service_principal_owners
}
