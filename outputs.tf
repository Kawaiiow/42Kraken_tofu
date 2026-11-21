output "network" {
  description = "Summary of the provisioned virtual network"
  value = {
    name       = module.network.network_name
    id         = module.network.network_id
    gateway_ip = module.network.gateway_ip
    cidr       = module.network.network_cidr
    domain     = module.network.domain_name
  }
}

output "base_image" {
  description = "Cached base image volume details"
  value = {
    name = libvirt_volume.ubuntu_base.name
    pool = libvirt_volume.ubuntu_base.pool
  }
}

output "vms" {
  description = "Summary of provisioned virtual machine instances"
  value = {
    for k, v in module.vm : k => {
      id             = v.id
      name           = v.name
      vcpu           = v.vcpu
      memory_mb      = v.memory
      root_volume_id = v.root_volume_id
      mac_address    = v.mac_address
      static_ip      = var.vms[k].ip_address
      virsh_console  = "virsh console ${v.name}"
      ssh_hint       = "ssh ${var.vms[k].username}@${coalesce(var.vms[k].ip_address, "<dhcp_ip>")}"
    }
  }
}
