module "gcp_networks" {
  source = "../modules/gcp-networks"

  project_id     = var.project_id
  default_region = var.default_region

  networks = {
    prod-network = {
      network = {
        name        = "prod-vpc"
        enable_ipv6 = false
        asn         = 64512
        subnets = [
          {
            name       = "prod-subnet"
            cidr       = "10.0.0.0/24"
            region     = var.default_region
            stack_type = "IPV4_ONLY"
          }
        ]
        firewall_rules = []
      }
    }

    dev-network = {
      network = {
        name        = "dev-vpc"
        enable_ipv6 = false
        asn         = 64513
        subnets = [
          {
            name       = "dev-subnet"
            cidr       = "10.0.1.0/24"
            region     = var.default_region
            stack_type = "IPV4_ONLY"
          }
        ]
        firewall_rules = [
          {
            name         = "allow-ssh"
            protocol     = "tcp"
            ports        = ["22"]
            from_sources = ["0.0.0.0/0"]
          }
        ]
      }
    }
  }
}
