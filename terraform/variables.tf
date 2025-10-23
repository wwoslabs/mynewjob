variable "resource_group_name" {
  type    = string
  default = "truckco-rg"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "vnet_name" {
  type    = string
  default = "truckco-vnet"
}

variable "address_space" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_name" {
  type    = string
  default = "truckco-subnet"
}

variable "subnet_prefix" {
  type    = string
  default = "10.0.1.0/24"
}

variable "vm_size" {
  type    = string
  default = "Standard_B1s"
}

variable "admin_username" {
  type    = string
  default = "truckcoadmin"
}

variable "ssh_public_key_path" {
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "my_ip_cidr" {
  type        = string
  default     = "10.2.82.43/32"
}

variable "ansible_inventory_path" {
  type    = string
  default = "../ansible/hosts.ini"
}
