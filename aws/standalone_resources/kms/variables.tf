variable "prefix" {
  description = "The prefix used in resource naming."
  type        = string
}

variable "app_environment" {
  description = "The application environment (e.g. dev, prod, staging)."
  type        = string
}

variable "description" {
  description = "Description for the KMS key."
  type        = string
}

variable "deletion_window_in_days" {
  description = "Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. Defaults to 30 days."
  type        = number
  default     = 30
}

variable "enable_key_rotation" {
  description = "Specifies whether key rotation is enabled."
  type        = bool
  default     = false
}

variable "multi_region" {
  description = "Specifies whether the key is a multi-region key."
  type        = bool
  default     = false
}

variable "key_name" {
  description = "Name for the KMS key alias."
  type        = string
}
