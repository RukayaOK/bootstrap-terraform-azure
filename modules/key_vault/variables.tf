##### GENERAL #####
variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "location" {
  type        = string
  description = "Resource location"
}

##### KEY VAULT #####
variable "key_vault_name" {
  type        = string
  description = "Resource location"
}

variable "tenant_id" {
  type        = string
  description = "Resource location"
}

variable "sku_name" {
  type        = string
  description = "Key Vault SKU"
}

variable "enabled_for_deployment" {
  type        = bool
  description = "Key Vault Enabled for Deployment"
  default     = true
}

variable "enabled_for_disk_encryption" {
  type        = bool
  description = "Key Vault Enabled disk encryption"
  default     = true
}

variable "enabled_for_template_deployment" {
  type        = bool
  description = "Key Vault Enabled for Template Deployment"
  default     = true
}

variable "soft_delete_retention_days" {
  type        = number
  description = "Key Vault soft deletion retention days"
}

variable "purge_protection_enabled" {
  type        = bool
  description = "Key Vault purge protection"
}

variable "network_acls" {
  description = "Network rules to apply to key vault."
  type = object({
    bypass                     = string,
    default_action             = string,
    ip_rules                   = list(string),
    virtual_network_subnet_ids = list(string),
  })
  default = null
}

variable "access_policies" {
  description = "Map of access policies for an object_id (user, service principal, security group) to backend."
  type = list(object({
    object_id               = string,
    certificate_permissions = list(string),
    key_permissions         = list(string),
    secret_permissions      = list(string),
    storage_permissions     = list(string),
  }))
  default = []
}
