locals {
  gateway_ip  = cidrhost(var.network_cidr, 1)
  dhcp_start  = var.dhcp_start_ip != null ? var.dhcp_start_ip : cidrhost(var.network_cidr, 2)
  dhcp_end    = var.dhcp_end_ip != null ? var.dhcp_end_ip : cidrhost(var.network_cidr, 254)
  cidr_prefix = tonumber(split("/", var.network_cidr)[1])
}

resource "libvirt_network" "network" {
  name      = var.network_name
  autostart = var.autostart

  forward = {
    mode = "nat"
  }

  domain = {
    name = var.domain_name
  }

  ips = [
    {
      address = local.gateway_ip
      prefix  = local.cidr_prefix
      dhcp = var.dhcp_enabled ? {
        ranges = [
          {
            start = local.dhcp_start
            end   = local.dhcp_end
          }
        ]
        hosts = [
          for lease in var.static_leases : {
            mac  = lease.mac
            ip   = lease.ip
            name = lease.name != null ? lease.name : ""
          }
        ]
      } : null
    }
  ]
}
