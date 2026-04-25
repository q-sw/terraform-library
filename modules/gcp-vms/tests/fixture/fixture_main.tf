variable "project_id" {
  type = string
}

module "network" {
  source     = "../../../gcp-networks"
  project_id = var.project_id
  networks = {
    "test-net" = {
      network = {
        name        = "vm-test-vpc"
        enable_ipv6 = true
        subnets = [
          {
            name       = "subnet-dual"
            cidr       = "10.0.1.0/24"
            region     = "europe-west9"
            stack_type = "IPV4_IPV6"
          },
          {
            name       = "subnet-v4-only"
            cidr       = "10.0.2.0/24"
            region     = "europe-west9"
            stack_type = "IPV4_ONLY"
          }
        ]
      }
    }
  }
}

module "vms" {
  source     = "../../"
  project_id = var.project_id
  vms = {
    # Cas 1 : Le Routeur (Dual-Stack + IP Forwarding)
    "nixos-router" = {
      name              = "test-vm-router"
      machine_type      = "n2-standard-2"
      zone              = "europe-west9-a"
      image             = "projects/debian-cloud/global/images/family/debian-12"
      boot_disk_size_gb = 20
      tags              = ["router"] # Doit activer can_ip_forward
      metadata          = { "role" = "gateway" }
      network_interfaces = [{
        subnetwork_id = "projects/${var.project_id}/regions/europe-west9/subnetworks/subnet-dual"
        nic_type      = "GVNIC"
        stack_type    = "IPV4_IPV6"
      }]
    },
    # Cas 2 : VM Simple (IPv4 Only + Pas de forwarding)
    "simple-vm" = {
      name              = "test-vm-simple"
      machine_type      = "e2-medium"
      zone              = "europe-west9-a"
      image             = "projects/debian-cloud/global/images/family/debian-12"
      boot_disk_size_gb = 10
      tags              = ["web-server"] # Pas de tag "router"
      metadata          = { "env" = "test" }
      network_interfaces = [{
        subnetwork_id = "projects/${var.project_id}/regions/europe-west9/subnetworks/subnet-v4-only"
        nic_type      = "VIRTIO_NET"
        stack_type    = "IPV4_ONLY"
      }]
    },
    # Cas 3 : VM Multi-NIC (RFC-001)
    "multi-nic-vm" = {
      name              = "test-vm-multi"
      machine_type      = "n2-standard-4"
      zone              = "europe-west9-a"
      image             = "projects/debian-cloud/global/images/family/debian-12"
      boot_disk_size_gb = 30
      tags              = []
      metadata          = {}
      network_interfaces = [
        {
          subnetwork_id = "projects/${var.project_id}/regions/europe-west9/subnetworks/subnet-dual"
          nic_type      = "GVNIC"
          stack_type    = "IPV4_IPV6"
        },
        {
          subnetwork_id = "projects/${var.project_id}/regions/europe-west9/subnetworks/subnet-v4-only"
          nic_type      = "VIRTIO_NET"
          stack_type    = "IPV4_ONLY"
        }
      ]
    }
  }
  depends_on = [module.network]
}
