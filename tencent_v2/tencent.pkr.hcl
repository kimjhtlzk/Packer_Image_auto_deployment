variable "tc_secret_id" {
  type    = string
}

variable "tc_secret_key" {
  type    = string
}

variable "company" {
  type = string
}

variable "tc_disk_type" {
  type = string
}

variable "tc_instance_type" {
  type = string
}

variable "tc_vpc_id" {
  type = string
}

variable "tc_subnet_id" {
  type = string
}

variable "tc_region" {
  type = string
}

variable "tc_zone" {
  type = string
}

variable "tc_security_group_id" {
  type = string
}

variable "tc_image_share_accounts" {
  type = list(string)
}

variable "tc_image_copy_regions" {
  type = list(string)
}

variable "tc_associate_public_ip_address" {
  type = string
}

variable "default_service_name" {
  type = string
}
