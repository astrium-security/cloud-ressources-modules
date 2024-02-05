variable "customer_prefix" {
  type        = string
  description = "customer_prefix"
}

variable "tenant_name" {
  type        = string
  description = "tenant_name"
}

variable "ssh_key_ops" {
  description = "List of public SSH keys for operators"
  type        = list(string)
  default = [ 
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDSFuJbzduvQ1QzQiT2eG71bsHBBoMXSqo+x++p4IKy0dMYjGwTm13YfQYUcGpu1JXASjaafSJZjIrEPlAkadZPqi069mj+Ij81fLv5huhFkVV/fH8O5HBF/OpKT6r9kCry3MNAsiWWqkNAmHWnDuxHOTAGuGc4r2nwTpxOUNlvQfsdA8UlmaeylSC7uogujApqiEOpBlbbfqp8gwbr59OUAy1+CgNkCcHvS9OGd1EyI4Buq9k6PUDWOuapredmM1lOHQgqAjFiT4IAimL+vnp5iztJvHtqMi4XT9zfWDBaMSPlRH5LoTzTgQeLTJfuIR0bfko1wTzbW5+osbw3QlgRB/BespqiztVHPRSKcNO9SBVkSbK8OlDb97Sq3hTYu/AbsuTOYWwYFRTQadrViStcyfNo0yHjkvr2giZcUlcb12DL6AFlSLoxB2elut1sp3xBO+y+Rvfuiiej69+MtwuLKllyuVqZO+q8KJip313yRgDzVQgSevJmcblV8ba5+fW5pqMd9K8kxLviipyJ9ugPigVSEZRC+cZAhsjVOa2uYTacqawq/dOLRY6iwMaOztnmMweq3YovwoVEMTIqr5ZOpcHUi4l7SFdY5HIB/L8hh9RN/AQCE8OhO3w1G096K00evDuL6ZBEBqwb18O5JW24ODWdgvN6vgAwHuoYcmEIAw== ifrah.sacha@gmail.com"
  ]
}

