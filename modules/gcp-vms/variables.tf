variable "project_id" {
  type        = string
  description = "The GCP project ID where the VMs will be created."
}

variable "vms" {
  type = map(object({
    name              = string
    machine_type      = string
    zone              = string
    image             = string # Self-link ou nom de l'image NixOS personnalisée
    boot_disk_size_gb = number

    # Configuration multi-interface (RFC-001)
    network_interfaces = list(object({
      subnetwork_id = string
      nic_type      = string           # "VIRTIO_NET" or "GVNIC"
      stack_type    = string           # "IPV4_ONLY" or "IPV4_IPV6"
      network_ip    = optional(string) # Optionnel: IP interne statique
    }))

    tags = list(string)

    # Metadata pour l'initialisation (SSH keys, etc.)
    metadata = map(string)
  }))
  description = "A map of virtual machines to provision, supporting multi-NIC and custom images."
  default     = {}
}
