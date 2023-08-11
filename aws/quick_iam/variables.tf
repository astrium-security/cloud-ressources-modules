variable "prefix" {
  description = "Prefix for naming the resources."
  type        = string
}

variable "app_environment" {
  description = "Application environment for naming the resources."
  type        = string
}

variable "title" {
  description = "Title used for naming the resources."
  type        = string
}

variable "description" {
  description = "Description for the IAM policy."
  type        = string
}

variable "policy" {
  description = "IAM policy in JSON format."
  type        = string
}
