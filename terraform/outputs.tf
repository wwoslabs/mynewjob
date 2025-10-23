output "public_ip" {
  value       = azurerm_public_ip.web.ip_address
  description = "Public IP of the web VM."
}

output "vm_name" {
  value       = azurerm_linux_virtual_machine.vm.name
  description = "Name of the Linux VM."
}

output "ansible_inventory_path" {
  value       = local_file.ansible_inventory.filename
  description = "Path to the generated Ansible inventory file."
}
