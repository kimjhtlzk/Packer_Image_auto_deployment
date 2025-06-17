variable "default_service_name" {
  type = string
}

variable "aws_access_key" {
  type = string
}
variable "aws_secret_key" {
  type = string
}
variable "aws_region" {
  type = string
}

variable "aws_vpc_id" {
  type = string
}

variable "aws_subnet_id" {
  type = string
}

variable "aws_instance_type" {
  type = string
}

variable "aws_ami_users" {
  type = list(string)
}

variable "aws_ami_regions" {
  type = list(string)
}

variable "company" {
  type = string
}

#################################################################################
