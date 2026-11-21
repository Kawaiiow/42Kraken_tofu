variable "vm_name" {
  type        = string
  description = "Virtual machine hostname and libvirt domain name"
}

variable "vcpu" {
  type        = number
  default     = 2
  description = "Number of virtual CPUs allocated to the VM"
}

variable "memory" {
  type        = number
  default     = 2048
  description = "Memory size in megabytes (MiB) allocated to the VM"
}

variable "storage_pool_name" {
  type        = string
  default     = "default"
  description = "Target libvirt storage pool for VM disk and cloud-init ISO"
}

variable "base_volume_path" {
  type        = string
  description = "Full host path to base cloud image volume used for backing store"
}

variable "disk_size" {
  type        = number
  default     = 10737418240
  description = "Size of root disk volume in bytes (default 10GiB: 10737418240)"
}

variable "network_name" {
  type        = string
  default     = "default"
  description = "Name of the libvirt virtual network to attach the primary interface"
}

variable "mac_address" {
  type        = string
  default     = null
  description = "Optional static MAC address for the primary network interface"
}

variable "ssh_public_keys" {
  type        = list(string)
  default     = []
  description = "List of SSH public keys authorized for instance login"
}

variable "username" {
  type        = string
  default     = "ubuntu"
  description = "Default cloud-init administrative user name"
}

variable "timezone" {
  type        = string
  default     = "UTC"
  description = "System timezone to configure via cloud-init"
}

variable "packages" {
  type        = list(string)
  default     = ["qemu-guest-agent"]
  description = "List of packages installed via cloud-init on initial boot"
}

variable "custom_user_data" {
  type        = string
  default     = ""
  description = "Optional raw cloud-init YAML snippet appended to user-data"
}

variable "autostart" {
  type        = bool
  default     = true
  description = "Whether the virtual machine automatically boots with the host"
}

variable "wait_for_ip" {
  type        = bool
  default     = false
  description = "Whether OpenTofu blocks until the VM acquires an IP lease from DHCP"
}
