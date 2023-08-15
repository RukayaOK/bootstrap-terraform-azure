variable "service_principal_name" {
  type        = string
  description = "(Required) The display name of the application associated with this service principal."
}

variable "service_principal_owners" {
  type        = list(string)
  description = "(Optional) A set of object IDs of principals that will be granted ownership of the service principal. Supported object types are users or service principals. By default, no owners are assigned."
  default     = []
}

# Variables for OIDC
variable "oidc_organisation" {
  type        = string
  description = "(Optional) The OIDC Organisation e.g. GitHub"
  default     = null
}

# Variables for Service Principal Credentials
variable "password_policy_length" {
  type        = number
  description = "(Optional) The length of the string desired. The minimum value for length is 1 and, length must also be >= (min_upper + min_lower + min_numeric + min_special)."
  default     = 250
}

variable "password_policy_special" {
  type        = bool
  description = "(Optional) Include special characters in the result. These are !@#$%&*()-_=+[]{}<>:?. Default value is true."
  default     = false
}

variable "password_policy_upper" {
  type        = bool
  description = "(Optional) Include uppercase alphabet characters in the result. Default value is true."
  default     = false
}

variable "password_policy_number" {
  type        = bool
  description = "(Optional) Include numeric characters in the result. Default value is true."
  default     = false
}

variable "password_policy_expire_in_days" {
  type        = number
  description = " (Optional) Number of days till expiry."
  default     = 10
}

variable "password_policy_rotation_minutes" {
  type        = number
  description = "(Optional) Number of minutes to add to the base timestamp to configure the rotation timestamp. When the current time has passed the rotation timestamp, the resource will trigger recreation. At least one of the 'rotation_' arguments must be configured."
  default     = null
}

variable "password_policy_rotation_days" {
  type        = number
  description = "(Optional) Number of days to add to the base timestamp to configure the rotation timestamp. When the current time has passed the rotation timestamp, the resource will trigger recreation. At least one of the 'rotation_' arguments must be configured."
  default     = 7
}

variable "password_policy_rotation_months" {
  type        = number
  description = "(Optional) Number of months to add to the base timestamp to configure the rotation timestamp. When the current time has passed the rotation timestamp, the resource will trigger recreation. At least one of the 'rotation_' arguments must be configured."
  default     = null
}

variable "password_policy_rotation_years" {
  type        = number
  description = "(Optional) Number of years to add to the base timestamp to configure the rotation timestamp. When the current time has passed the rotation timestamp, the resource will trigger recreation. At least one of the 'rotation_' arguments must be configured."
  default     = null
}

variable "store_credentials_in_key_vault" {
  type        = bool
  description = "(Optional) Whether to store credentials in an Azure Key Vault."
  default     = false
}

variable "key_vault_id" {
  type        = string
  description = "(Optional) The ID of the Key Vault where the secret should be created."
  default     = null
}

# Service Principal Permissions
variable "service_principal_rbac_assignment" {
  type        = map(string)
  description = "(Optional) List of maps of resource ID to role to assign the Service Principal."
  default     = {}
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
