variable project {
  description = "Project ID"
}
variable region {
  description = "Region"
  # Значение по умолчанию
  default = "europe-west1-b"
}
variable public_key_path {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}
variable disk_image {
  description = "Disk image"
}
variable connection_key {
  description = "private key for provisioners connection"
}
variable instance_zone {
  description = "instance creation zone"
  default     = "europe-west1-b"
}

variable "app_port" {
  description = "reddit-hc port"  
  default = 9292
}

