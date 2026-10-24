variable "resource_group_name" {
  type        = string
  description = "Name of the Azure Resource Group"
  default     = "rg-devops-cicd-prod"
}

variable "location" {
  type        = string
  description = "Azure region where resources will be provisioned"
  default     = "eastus"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g. dev, staging, prod)"
  default     = "production"
}

variable "vnet_address_space" {
  type        = list(string)
  description = "Virtual Network CIDR address space"
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_prefix" {
  type        = list(string)
  description = "Subnet CIDR address prefix"
  default     = ["10.0.1.0/24"]
}

variable "admin_username" {
  type        = string
  description = "Administrator username for the Linux VM"
  default     = "azureuser"
}

variable "ssh_public_key" {
  type        = string
  description = "Public SSH key text for VM authentication. If empty, the file at ssh_public_key_path will be read."
  default     = ""
}

variable "ssh_public_key_path" {
  type        = string
  description = "Local path to the SSH public key file (used if ssh_public_key is not directly provided)"
  default     = "~/.ssh/id_rsa.pub"
}

variable "vm_size" {
  type        = string
  description = "Size / SKU of the Azure Virtual Machine"
  default     = "Standard_B1s" # 1 vCPU, 1 GB RAM (Cost-effective & Free Tier eligible)
}
