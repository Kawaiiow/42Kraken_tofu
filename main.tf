# Base Ubuntu cloud image cached in the storage pool
# All VM instances share this backing store using Copy-on-Write (COW)
resource "libvirt_volume" "ubuntu_base" {
  name = "${var.project}-ubuntu-base.qcow2"
  pool = var.storage_pool_name

  create = {
    content = {
      url = var.ubuntu_image_url
    }
  }
}

# Dedicated isolated NAT virtual network with DHCP and DNS
module "network" {
  source = "./modules/network"

  network_name  = "${var.project}-net"
  network_cidr  = var.network_cidr
  domain_name   = "${lower(var.project)}.local"
  autostart     = var.autostart
  static_leases = local.static_leases
}

# Modular virtual machines instantiated across the vms map
module "vm" {
  source   = "./modules/vm"
  for_each = var.vms

  vm_name           = "${var.project}-${each.key}"
  vcpu              = each.value.vcpu
  memory            = each.value.memory
  disk_size         = each.value.disk_size
  storage_pool_name = var.storage_pool_name
  base_volume_path  = libvirt_volume.ubuntu_base.path
  network_name      = module.network.network_name
  mac_address       = each.value.mac_address
  ssh_public_keys   = local.resolved_ssh_keys
  username          = each.value.username
  timezone          = each.value.timezone
  packages          = each.value.packages
  custom_user_data  = each.value.custom_user_data
  autostart         = coalesce(each.value.autostart, var.autostart)
  wait_for_ip       = each.value.wait_for_ip
}
