variable "container_name" {
  type        = string
  description = "(Required) The name of the Container which should be created within the Storage Account."
}

variable "storage_account_name" {
  type        = string
  description = "(Required) The name of the Container which should be created within the Storage Account."
}

variable "container_access_type" {
  type        = string
  description = "(Optional) The Access Level configured for this Container. Possible values are blob, container or private. Defaults to private."
  default     = "private"
}

variable "container_metadata" {
  type        = map(string)
  description = "(Optional) The Access Level configured for this Container. Possible values are blob, container or private. Defaults to private."
  default     = null
}
