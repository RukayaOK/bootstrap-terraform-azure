##### GENERAL #####
variable "location" {
  description = "Location of resources"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group Name"
  type        = string
}

##### KEY VAULT #####
variable "key_vault_name" {
  type        = string
  description = "Key Vault Name"
}

variable "key_vault_sku_name" {
  type        = string
  description = "Key Vault SKU"
}

variable "key_vault_soft_delete_retention_days" {
  type        = number
  description = "Key Vault soft deletion retention days"
}

variable "key_vault_purge_protection_enabled" {
  type        = bool
  description = "Key Vault purge protection"
}

variable "key_vault_network_acls" {
  description = "Network rules to apply to key vault."
  type = object({
    bypass                     = string,
    default_action             = string,
    ip_rules                   = list(string),
    virtual_network_subnet_ids = list(string),
  })
  default = null
}

##### STORAGE ACCOUNT #####
variable "storage_account_name" {
  description = "Storage account name"
  type        = string
}

variable "account_kind" {
  description = "Storage account name"
  type        = string
}

variable "replication_type" {
  description = "Storage account replication type - i.e. LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  type        = string
}

variable "account_tier" {
  description = "Defines the Tier to use for this storage account (Standard or Premium)."
  type        = string
}

variable "shared_access_key_enabled" {
  description = "Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key"
  type        = bool
}

variable "min_tls_version" {
  description = "The minimum supported TLS version for the storage account."
  type        = string
}

variable "infrastructure_encryption_enabled" {
  description = "Is infrastructure encryption enabled? Changing this forces a new resource to be created."
  type        = bool
}

variable "default_network_rule" {
  description = "Specifies the default action of allow or deny when no other network rules match"
  type        = string
  default     = "Deny"

  validation {
    condition     = (contains(["deny", "allow"], lower(var.default_network_rule)))
    error_message = "The default_network_rule must be either \"Deny\" or \"Allow\"."
  }
}

variable "access_list" {
  description = "The minimum supported TLS version for the storage account."
  type        = map(any)
}

##### STORAGE ACCOUNT CONTAINER #####
variable "container_name" {
  type        = string
  description = "(Required) The name of the Container which should be created within the Storage Account."
}

##### STORAGE ACCOUNT KEY VAULT SECRET #####
variable "storage_account_access_key_secret_name" {
  type        = string
  description = "Key Vault secret name for Storage account access key"
}

variable "terraform_backend_config_secret_name" {
  type        = string
  description = "Key Vault secret name for Terraform backend configuration"
}

variable "terraform_backend_key_name" {
  type        = string
  description = "Name of the Terraform backend key"
}


# ##### SERVICE PRINCIPAL #####
variable "service_principal_name" {
  type        = string
  description = "(Required) The display name of the application associated with this service principal."
}

variable "azuread_directory_roles" {
  type        = list(string)
  description = "(Optional) List of Azure Active Directory Role to assign to the Service Principal."
  default     = []
}

variable "azuread_directory_roles_object_id" {
  type        = string
  description = "(Optional) The object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies."
  default     = null
}

variable "graph_api_permissions" {
  type        = list(string)
  description = "(Optional) List of Microsoft Graph Permissions to assign to Service Principal"
  default     = []
}

##### SERVICE PRINCIPAL KEY VAULT SECRET #####
variable "service_principal_application_id_secret_name" {
  type        = string
  description = "Key Vault secret name for Service Principal Application ID"
}

variable "service_principal_secret_name" {
  type        = string
  description = "Key Vault secret name for Service Principal Secret"
}

variable "terraform_environment_variables_secret_name" {
  type        = string
  description = "Key Vault secret name for Service Principal Secret"
}