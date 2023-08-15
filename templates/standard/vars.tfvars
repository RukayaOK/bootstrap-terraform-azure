location = "uksouth"

##### KEY VAULT #####
key_vault_name                       = "terraformkv874"
key_vault_sku_name                   = "standard"
key_vault_soft_delete_retention_days = 7
key_vault_purge_protection_enabled   = false
key_vault_network_acls = {
  bypass                     = "AzureServices"
  default_action             = "Deny"
  ip_rules                   = ["82.16.6.176"]
  virtual_network_subnet_ids = []
}

##### STORAGE ACCOUNT #####
storage_account_name              = "terraformsa874"
account_kind                      = "StorageV2"
replication_type                  = "LRS"
account_tier                      = "Standard"
shared_access_key_enabled         = true
min_tls_version                   = "TLS1_2"
infrastructure_encryption_enabled = true
default_network_rule              = "Allow"
access_list = {
  MY_IP = "82.16.6.176"
}

##### STORAGE ACCOUNT CONTAINER #####
container_name = "terraformcontainer"

##### STORAGE ACCOUNT KEY VAULT SECRETS #####
storage_account_access_key_secret_name = "storage-account-access-key"
terraform_backend_config_secret_name   = "terraform-backend-config"
terraform_backend_key_name             = "example-tf-state"

##### SERVICE PRINCIPAL #####
azuread_directory_roles = [
  "Compliance administrator",
  "Security administrator"
]
graph_api_permissions = [
  "Directory.ReadWrite.All",
  "RoleManagement.ReadWrite.Directory",
  "Application.ReadWrite.OwnedBy",
  "DelegatedPermissionGrant.ReadWrite.All",
  "AppRoleAssignment.ReadWrite.All",
  "Group.ReadWrite.All"
]

##### SERVICE PRINCIPAL KEY VAULT SECRETS #####
service_principal_application_id_secret_name = "service-principal-application-id"
service_principal_secret_name                = "service-principal-secret"

##### TERRAFORM CREDENTIALS #####
terraform_environment_variables_secret_name = "terraform-environment-variables"