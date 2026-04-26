module "gcp_networks" {
  source = "../modules/gcp-networks"

  project_id     = var.project_id
  default_region = var.default_region

  networks = {
    example-network = {
      network = {
        name        = "example-vpc"
        enable_ipv6 = false
        asn         = 64512
        subnets = [
          {
            name       = "example-subnet"
            cidr       = "10.0.0.0/24"
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
    static-ip-vm = {
      name              = "static-ip-vm"
      machine_type      = "e2-medium"
      zone              = "${var.default_region}-a"
      image             = "debian-cloud/debian-12"
      boot_disk_size_gb = 20

      network_interfaces = [
        {
          subnetwork_id = module.gcp_networks.subnetwork_ids["example-network.example-subnet"]
          nic_type      = "GVNIC"
          stack_type    = "IPV4_ONLY"
          network_ip    = "10.0.0.100"
        }
      ]

      tags = []

      metadata = {}
    }
  }
}
