variable "project" {
  type        = string
  default     = "Kraken"
  description = "Project or workload identifier used to prefix resources"
}

variable "libvirt_uri" {
  type        = string
  default     = "qemu:///system"
  description = "Connection URI for libvirtd hypervisor"
}

variable "storage_pool_name" {
  type        = string
  default     = "default"
  description = "Name of the target libvirt storage pool for disks and cloud-init images"
}

variable "storage_pool_path" {
  type        = string
  default     = "/var/lib/libvirt/images/"
  description = "Host directory path for the storage pool"
}

variable "ubuntu_image_url" {
  type        = string
  default     = "https://cloud-images.ubuntu.com/releases/resolute/release/ubuntu-26.04-server-cloudimg-amd64.img"
  description = "Base Ubuntu cloud image URL (qcow2 format)"
}

variable "ssh_public_key_path" {
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
  description = "Path to host SSH public key file for instance access"
}

variable "ssh_public_key" {
  type        = string
  default     = ""
  description = "Direct SSH public key string (takes precedence over ssh_public_key_path if specified)"
}

variable "autostart" {
  type        = bool
  default     = true
  description = "Default autostart behavior for virtual machines and virtual networks on host boot"
}

variable "network_cidr" {
  type        = string
  default     = "192.168.200.0/24"
  description = "CIDR subnet assigned to the managed NAT virtual network"
}

variable "vms" {
  type = map(object({
    vcpu                  = optional(number, 2)
    memory                = optional(number, 2048)
    disk_size             = optional(number, 10737418240)
    ip_address            = optional(string)
    mac_address           = optional(string)
    username              = optional(string, "ubuntu")
    password              = optional(string)
    sudo_require_password = optional(bool, false)
    ssh_pwauth            = optional(bool, false)
    timezone              = optional(string, "UTC")
    packages              = optional(list(string), ["qemu-guest-agent"])
    custom_user_data      = optional(string, "")
    autostart             = optional(bool)
    wait_for_ip           = optional(bool, false)
  }))
  default = {
    "node-01" = {
      vcpu   = 2
      memory = 2048
    }
  }
  description = "Map of virtual machine instances to provision and configure"
}
