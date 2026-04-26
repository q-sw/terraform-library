module "gcp_networks" {
  source = "../modules/gcp-networks"

  project_id     = var.project_id
  default_region = var.default_region

  networks = {
    network-a = {
      network = {
        name        = "vpc-a"
        enable_ipv6 = false
        asn         = 64512
        subnets = [
          {
            name       = "subnet-a"
            cidr       = "10.0.0.0/24"
            region     = var.default_region
            stack_type = "IPV4_ONLY"
          }
        ]
        firewall_rules = []
      }
    }
    network-b = {
      network = {
        name        = "vpc-b"
        enable_ipv6 = false
        asn         = 64513
        subnets = [
          {
            name       = "subnet-b"
            cidr       = "10.0.1.0/24"
            region     = var.default_region
            stack_type = "IPV4_ONLY"
          }
        ]
        firewall_rules = []
      }
    }
  }
}

module "gcp_vms" {
  source = "../modules/gcp-vms"

  project_id = var.project_id

  vms = {
    multi-nic-vm = {
      name              = "multi-nic-vm"
      machine_type      = "e2-medium"
      zone              = "${var.default_region}-a"
      image             = "debian-cloud/debian-12"
      boot_disk_size_gb = 20

      network_interfaces = [
        {
          subnetwork_id = module.gcp_networks.subnetwork_ids["network-a.subnet-a"]
          nic_type      = "GVNIC"
          stack_type    = "IPV4_ONLY"
        },
        {
          subnetwork_id = module.gcp_networks.subnetwork_ids["network-b.subnet-b"]
          nic_type      = "GVNIC"
          stack_type    = "IPV4_ONLY"
        }
      ]

      tags = []

      metadata = {}
    }
  }
}
