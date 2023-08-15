# CREATE SERVICE PRINCIPAL PASSWORD
resource "time_rotating" "main" {
  rotation_minutes = try(var.password_policy_rotation_minutes, null)
  rotation_days    = try(var.password_policy_rotation_days, null)
  rotation_months  = try(var.password_policy_rotation_months, null)
  rotation_years   = try(var.password_policy_rotation_years, null)
}

# Will force the password to change every month
resource "random_password" "main" {
  keepers = {
    frequency = time_rotating.main.id
  }
  length  = var.password_policy_length
  special = var.password_policy_special
  upper   = var.password_policy_upper
  numeric = var.password_policy_number
}

resource "azuread_service_principal_password" "pwd" {
  service_principal_id = azuread_service_principal.main.id
  end_date             = timeadd(time_rotating.main.id, format("%sh", var.password_policy_expire_in_days * 24))

  lifecycle {
    create_before_destroy = false
  }
}

# resource "azurerm_key_vault_secret" "main" {
#   count        = var.store_credentials_in_key_vault == true ? 1 : 0
#   name         = "ARM-CLIENT-ID"
#   value        = azuread_application.main.application_id
#   key_vault_id = var.key_vault_id
# }

# resource "azurerm_key_vault_secret" "client_secret" {
#   count           = var.store_credentials_in_key_vault == true ? 1 : 0
#   name            = "ARM-CLIENT-SECRET"
#   value           = azuread_service_principal_password.pwd.value
#   key_vault_id    = var.key_vault_id
#   expiration_date = timeadd(time_rotating.pwd.id, format("%sh", var.password_policy_expire_in_days * 24))
# }
