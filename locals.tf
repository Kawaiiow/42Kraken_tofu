locals {
  name_prefix = var.project

  # Resolve SSH public key from direct string variable or file path
  resolved_ssh_keys = (
    var.ssh_public_key != "" ? [trimspace(var.ssh_public_key)] :
    fileexists(pathexpand(var.ssh_public_key_path)) ? [trimspace(file(pathexpand(var.ssh_public_key_path)))] :
    []
  )

  # Collect any static DHCP reservations defined in VM configurations
  static_leases = [
    for name, config in var.vms : {
      mac  = config.mac_address
      ip   = config.ip_address
      name = "${var.project}-${name}"
    }
    if config.ip_address != null && config.mac_address != null
  ]
}
