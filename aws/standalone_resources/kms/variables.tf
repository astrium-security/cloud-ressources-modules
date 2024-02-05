variable "description" {
  type        = string
  description = "Description for the KMS key"
}

variable "deletion_window_in_days" {
  type        = number
  description = "Key deletion window in days"
  default     = 10
}