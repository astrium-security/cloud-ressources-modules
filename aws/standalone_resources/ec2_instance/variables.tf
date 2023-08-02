variable "total_instance_to_create" {
  description = "Total number of instances to create"
  type        = number
}

variable "default_ami" {
  description = "The ID of the AMI to use for the instance"
  type        = string
  default     =  "ami-018de3a6e45331551"
}

variable "instance_type" {
  description = "The type of instance to start"
  type        = string
  default     =  "t2.nano"
}

variable "subnet_id" {
  description = "VPC Subnet ID"
  type        = string
}

variable "security_group" {
  description = "Array of VPC Security Group IDs"
  type        = list(string)
}

variable "set_public_ip_address" {
  description = "Associate a public IP address with the instance"
  type        = bool
}

variable "key_name" {
  description = "The key name to use for the instance"
  type        = string
}

variable "user_data" {
  description = "The user data to provide when launching the instance"
  type        = string
}

variable "volume_size" {
  description = "The size of the root volume in gibibytes(GiB)"
  type        = number
}

variable "root_volume_type" {
  description = "The type of volume. Can be 'standard', 'gp2', 'io1', 'io2', or 'sc1'."
  type        = string
}

variable "instance_name" {
  description = "The name to assign to the instance"
  type        = string
}
