variable "noncurrent_version_expiration" {
  description = "Number of days before the noncurrent version of an S3 object expires"
  type        = number
  default     = 30  # Assuming a default of 30 days, but you can change it as needed.
}
