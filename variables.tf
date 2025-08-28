variable "prefix" {
  default = "tfvmex"
}

variable "resource_group_name" {
  default = "mate-terraform-task-3"
}

variable "vnet_name" {
  default = "tfvnetname"
}

variable "subnet_name" {
  default = "tfsubnetname"
}

variable "nic_name" {
  default = "tfnicname"
}

variable "public_ip_name" {
  default = "tfpublicipname"
}

variable "vm_name" {
  default = "tfvmname"
}

variable "admin_username" {
  type = string
}

variable "private_key_path" {
  type = string
}