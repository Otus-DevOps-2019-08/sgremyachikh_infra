variable zone {
  description = "instance creation zone"
  default     = "europe-west1-b"
}
variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}
variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable machine_type {
  description = "type of instance"
  default     = "g1-small"
}