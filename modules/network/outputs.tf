output "network_name" {
  description = "The name of the virtual network"
  value       = libvirt_network.network.name
}

output "network_id" {
  description = "The ID of the virtual network"
  value       = libvirt_network.network.id
}

output "gateway_ip" {
  description = "The gateway IP address of the virtual network"
  value       = local.gateway_ip
}

output "network_cidr" {
  description = "The CIDR subnet of the virtual network"
  value       = var.network_cidr
}

output "domain_name" {
  description = "The DNS domain name configured on the virtual network"
  value       = var.domain_name
}
