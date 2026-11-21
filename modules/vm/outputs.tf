output "id" {
  description = "The unique identifier of the libvirt domain"
  value       = libvirt_domain.instance.id
}

output "name" {
  description = "The name of the virtual machine domain"
  value       = libvirt_domain.instance.name
}

output "vcpu" {
  description = "The number of vCPUs allocated to the virtual machine"
  value       = libvirt_domain.instance.vcpu
}

output "memory" {
  description = "The memory allocated to the virtual machine in MiB"
  value       = libvirt_domain.instance.memory
}

output "root_volume_id" {
  description = "The ID of the root storage volume"
  value       = libvirt_volume.root.id
}

output "mac_address" {
  description = "The MAC address configured on the virtual machine interface"
  value       = var.mac_address
}
