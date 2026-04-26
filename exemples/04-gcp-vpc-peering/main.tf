
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

module "gcp_vpc_peering" {
  source = "../modules/gcp-vpc-peering"

  local_network_id   = module.gcp_networks.network_ids["network-a"]
  local_network_name = "vpc-a"

  peer_network_id   = module.gcp_networks.network_ids["network-b"]
  peer_network_name = "vpc-b"

  export_custom_routes                = true
  import_custom_routes                = true
  export_subnet_routes_with_public_ip = true
  import_subnet_routes_with_public_ip = true
}
