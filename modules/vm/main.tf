resource "libvirt_volume" "root" {
  name     = "${var.vm_name}-root.qcow2"
  pool     = var.storage_pool_name
  capacity = var.disk_size
  target = {
    format = {
      type = "qcow2"
    }
  }
  backing_store = {
    path = var.base_volume_path
    format = {
      type = "qcow2"
    }
  }
}

locals {
  cloudinit_user_data = templatefile("${path.module}/templates/user_data.tftpl", {
    username         = var.username
    ssh_public_keys  = var.ssh_public_keys
    packages         = var.packages
    timezone         = var.timezone
    custom_user_data = var.custom_user_data
  })

  cloudinit_meta_data = <<-EOF
    instance-id: ${var.vm_name}
    local-hostname: ${var.vm_name}
  EOF
}

resource "libvirt_cloudinit_disk" "ci" {
  name      = "${var.vm_name}-ci"
  meta_data = local.cloudinit_meta_data
  user_data = local.cloudinit_user_data

  network_config = <<-EOF
    version: 2
    ethernets:
      all-en:
        match:
          name: "en*"
        dhcp4: true
      all-eth:
        match:
          name: "eth*"
        dhcp4: true
  EOF
}

resource "libvirt_volume" "ci_vol" {
  name = "${var.vm_name}-ci.iso"
  pool = var.storage_pool_name
  create = {
    content = {
      url = libvirt_cloudinit_disk.ci.path
    }
  }
}

resource "libvirt_domain" "instance" {
  name        = var.vm_name
  type        = "kvm"
  memory      = var.memory
  memory_unit = "MiB"
  vcpu        = var.vcpu
  autostart   = var.autostart
  running     = true

  features = {
    acpi = true
    apic = {}
  }

  cpu = {
    mode = "host-passthrough"
  }

  os = {
    type         = "hvm"
    type_arch    = "x86_64"
    type_machine = "q35"
    sm_bios = {
      mode = "sysinfo"
    }
    boot_devices = [
      {
        dev = "hd"
      }
    ]
  }

  sys_info = [
    {
      smbios = {
        system = {
          entry = [
            {
              name  = "serial"
              value = "ds=nocloud"
            }
          ]
        }
      }
    }
  ]

  devices = {
    disks = [
      {
        device = "disk"
        driver = {
          name = "qemu"
          type = "qcow2"
        }
        target = {
          dev = "vda"
          bus = "virtio"
        }
        source = {
          volume = {
            pool   = libvirt_volume.root.pool
            volume = libvirt_volume.root.name
          }
        }
      },
      {
        device    = "cdrom"
        read_only = true
        driver = {
          name = "qemu"
          type = "raw"
        }
        target = {
          dev = "sda"
          bus = "sata"
        }
        source = {
          volume = {
            pool   = libvirt_volume.ci_vol.pool
            volume = libvirt_volume.ci_vol.name
          }
        }
      }
    ]

    interfaces = [
      {
        type = "network"
        model = {
          type = "virtio"
        }
        source = {
          network = {
            network = var.network_name
          }
        }
        mac = var.mac_address != null ? { address = var.mac_address } : null
        wait_for_ip = var.wait_for_ip ? {
          source  = "lease"
          timeout = 300
        } : null
      }
    ]

    consoles = [
      {
        target = {
          port = 0
          type = "serial"
        }
      }
    ]

    graphics = [
      {
        vnc = {
          auto_port = true
          listen    = "127.0.0.1"
        }
      }
    ]
  }
}
