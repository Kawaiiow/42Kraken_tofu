variable "network_name" {
  type        = string
  description = "Name of the libvirt virtual network"
}

variable "network_cidr" {
  type        = string
  default     = "192.168.200.0/24"
  description = "CIDR subnet assigned to the virtual network"
}

variable "domain_name" {
  type        = string
  default     = "kraken.local"
  description = "DNS search domain name for the virtual network"
}

variable "autostart" {
  type        = bool
  default     = true
  description = "Whether the virtual network automatically starts on host boot"
}

variable "dhcp_enabled" {
  type        = bool
  default     = true
  description = "Whether to enable DHCP on the virtual network"
}

variable "dhcp_start_ip" {
  type        = string
  default     = null
  description = "Optional custom starting IP for DHCP range; defaults to the 2nd usable host IP in the CIDR"
}

variable "dhcp_end_ip" {
  type        = string
  default     = null
  description = "Optional custom ending IP for DHCP range; defaults to the 254th host IP in the CIDR"
}

variable "static_leases" {
  type = list(object({
    mac  = string
    ip   = string
    name = optional(string)
  }))
  default     = []
  description = "List of static DHCP host reservations with MAC and IP addresses"
}
