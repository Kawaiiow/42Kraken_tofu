# 42Kraken Libvirt KVM Ubuntu VMs (OpenTofu)

Modular, production-ready OpenTofu configuration for provisioning Ubuntu KVM virtual machines via `libvirt`.

- **OpenTofu Version**: `v1.13.9`
- **Provider**: `dmacvicar/libvirt` `v0.9.9` (modern Plugin Framework schema)
- **Architecture**: Separated into reusable `modules/network` and `modules/vm` modules with shared COW image caching.

---

## Architecture Overview

```
.
├── modules/
│   ├── network/                # Libvirt virtual network module
│   │   ├── main.tf             # 0.9.9 libvirt_network (NAT, DNS, DHCP)
│   │   ├── outputs.tf          # Network metadata outputs
│   │   ├── variables.tf        # Network CIDR, domain, static lease inputs
│   │   └── version.tf          # Provider pinning
│   └── vm/                     # Compute instance module
│       ├── main.tf             # Root volume, cloud-init ISO, libvirt domain
│       ├── outputs.tf          # VM attributes and identifiers
│       ├── templates/
│       │   └── user_data.tftpl # Cloud-config YAML template
│       ├── variables.tf        # CPU, RAM, disk, network, user parameters
│       └── version.tf          # Provider pinning
├── locals.tf                   # SSH key resolution & static lease mappings
├── main.tf                     # Root base image cache, network & VM calls
├── outputs.tf                  # Cluster summary & connection helpers
├── provider.tf                 # Libvirt provider configuration
├── tofu.tfvars.example         # Multi-node sample configuration
├── variables.tf                # Global input variables and `vms` map
└── version.tf                  # Root OpenTofu and provider constraints
```

### Highlights:
1. **Shared Base Image Caching**: The base Ubuntu cloud image is downloaded once into the libvirt storage pool (`libvirt_volume.ubuntu_base`). Each VM instance creates a lightweight copy-on-write (COW) QCOW2 volume referencing the base image as its `backing_store`.
2. **Horizontal Scalability**: Add or remove VMs easily by declaring entries in the `vms` map in `tofu.tfvars`.
3. **Automated Cloud-Init**: Generates ISO volumes with SSH access, passwordless sudo, custom packages, timezone, and `growpart` automatic root partition expansion.
4. **Console Access**: Configures native serial consoles on each guest for direct management via `virsh console <domain>`.
5. **Static & Dynamic IP Support**: Combine dynamic DHCP address pools with fixed MAC-to-IP reservations.

---

## Quickstart

### 1. Prerequisites
- OpenTofu `v1.13.9` (or `>= 1.6.0`)
- `libvirt` daemon running locally (`virsh uri` -> `qemu:///system`)
- Active storage pool (default: `default` at `/var/lib/libvirt/images`)
- SSH key pair (default: `~/.ssh/id_ed25519.pub`)

### 2. Configure Variables
Copy the example variables file:
```bash
cp tofu.tfvars.example tofu.tfvars
```
Edit `tofu.tfvars` to customize your instances, resource limits, or network CIDR.

### 3. Initialize & Validate
```bash
tofu init
tofu validate
```

### 4. Review Plan
```bash
tofu plan
```

### 5. Deploy Infrastructure
```bash
tofu apply
```

### 6. Access Virtual Machines
- **Via SSH**:
  ```bash
  ssh ubuntu@<vm_ip>
  ```
- **Via Serial Console**:
  ```bash
  virsh console Kraken-<node_name>
  # Press Enter to get prompt; exit using Ctrl + ]
  ```

---

## Expanding the Cluster

To add more VMs, add a new key under `vms` in your `tofu.tfvars`:

```hcl
vms = {
  "worker-01" = {
    vcpu      = 2
    memory    = 2048
    disk_size = 10737418240
  }
  "worker-02" = {
    vcpu      = 4
    memory    = 4096
    disk_size = 21474836480
    packages  = ["qemu-guest-agent", "docker.io"]
  }
}
```
Run `tofu apply` to provision the new node without altering existing instances.
