data "azurerm_client_config" "current" {}


locals {
  key_vault_access_policies = [
    {
      object_id       = data.azurerm_client_config.current.object_id,
      key_permissions = []
      secret_permissions = [
        "Backup",
        "Delete",
        "Get",
        "List",
        "Recover",
        "Restore",
        "Set",
        "Purge"
      ],
      certificate_permissions = [],
      storage_permissions     = []
    }
  ]

  terraform_backend_secret_value = <<-EOT
      "terraform {
            backend "azurerm" {
                resource_group_name  = ${azurerm_resource_group.main.name}
                storage_account_name = ${module.storage_account.name}
                container_name       = ${module.storage_account_container.name}
                key                  = ${var.terraform_backend_key_name}
            }
        }"
      EOT

  service_principal_rbac_assignment = {
    "/subscriptions/${data.azurerm_client_config.current.subscription_id}" = "Owner"
  }

  terraform_environment_variables_secret_value = <<-EOT
      "
        #!/bin/bash
        export ARM_CLIENT_ID="${module.service_principal.service_principal_application_id}"
        export ARM_CLIENT_SECRET="${module.service_principal.service_principal_secret}"
        export ARM_TENANT_ID="${data.azurerm_client_config.current.tenant_id}"
        export ARM_SUBSCRIPTION_ID="${data.azurerm_client_config.current.subscription_id}" 
      "
      EOT
}


resource "azurerm_resource_group" "main" {
  location = var.location
  name     = var.resource_group_name

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

##### KEY VAULT #####
module "key_vault" {
  source = "../../modules/key_vault"

  resource_group_name        = azurerm_resource_group.main.name
  location                   = var.location
  key_vault_name             = var.key_vault_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = var.key_vault_sku_name
  soft_delete_retention_days = var.key_vault_soft_delete_retention_days
  purge_protection_enabled   = var.key_vault_purge_protection_enabled
  network_acls               = var.key_vault_network_acls
  access_policies            = local.key_vault_access_policies
}

##### STORAGE ACCOUNT #####
module "storage_account" {
  source = "../../modules/storage_account"

  resource_group_name  = azurerm_resource_group.main.name
  location             = var.location
  storage_account_name = var.storage_account_name

  account_kind = var.account_kind

  replication_type                  = var.replication_type
  account_tier                      = var.account_tier
  shared_access_key_enabled         = var.shared_access_key_enabled
  min_tls_version                   = var.min_tls_version
  infrastructure_encryption_enabled = var.infrastructure_encryption_enabled
  default_network_rule              = var.default_network_rule
  access_list                       = var.access_list
}

##### STORAGE ACCOUNT CONTAINER #####
module "storage_account_container" {
  source = "../../modules/storage_account/container"

  depends_on = [module.storage_account]

  container_name       = var.container_name
  storage_account_name = module.storage_account.name
}

##### STORAGE ACCOUNT SECRETS #####
module "storage_account_secret" {
  source = "../../modules/key_vault/secrets"

  depends_on = [module.key_vault, module.storage_account]

  secret_name  = var.storage_account_access_key_secret_name
  secret_value = module.storage_account.primary_access_key
  key_vault_id = module.key_vault.key_vault_id
}

module "terraform_backend_secret" {
  source = "../../modules/key_vault/secrets"

  depends_on = [module.key_vault, module.storage_account]

  secret_name  = var.terraform_backend_config_secret_name
  secret_value = local.terraform_backend_secret_value
  key_vault_id = module.key_vault.key_vault_id
}

# ##### SERVICE PRINCIPAL #####
module "service_principal" {

  source = "../../modules/service_principal"

  service_principal_name            = var.service_principal_name
  service_principal_rbac_assignment = local.service_principal_rbac_assignment
  azuread_directory_roles           = var.azuread_directory_roles
  graph_api_permissions             = var.graph_api_permissions
}

##### SERVICE PRINCIPAL SECRETS #####
module "service_principal_application_id" {
  source = "../../modules/key_vault/secrets"

  depends_on = [module.key_vault, module.service_principal]

  secret_name  = var.service_principal_application_id_secret_name
  secret_value = module.service_principal.service_principal_application_id
  key_vault_id = module.key_vault.key_vault_id
}

module "service_principal_secret" {
  source = "../../modules/key_vault/secrets"

  depends_on = [module.key_vault, module.service_principal]

  secret_name  = var.service_principal_secret_name
  secret_value = module.service_principal.service_principal_secret
  key_vault_id = module.key_vault.key_vault_id
}

module "terraform_environment_variables_secret" {
  source = "../../modules/key_vault/secrets"

  depends_on = [module.key_vault, module.service_principal]

  secret_name  = var.service_principal_secret_name
  secret_value = local.terraform_environment_variables_secret_value
  key_vault_id = module.key_vault.key_vault_id
}
