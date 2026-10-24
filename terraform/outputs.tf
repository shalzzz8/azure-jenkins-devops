output "resource_group_name" {
  description = "The name of the created resource group"
  value       = azurerm_resource_group.rg.name
}

output "public_ip_address" {
  description = "Public IP address of the Azure Virtual Machine"
  value       = azurerm_public_ip.pip.ip_address
}

output "ssh_connection_command" {
  description = "Command to SSH into the deployed Virtual Machine"
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.pip.ip_address}"
}

output "app_url" {
  description = "Direct Web URL to access the deployed application"
  value       = "http://${azurerm_public_ip.pip.ip_address}"
}

output "vm_name" {
  description = "Name of the Azure Virtual Machine"
  value       = azurerm_linux_virtual_machine.vm.name
}
