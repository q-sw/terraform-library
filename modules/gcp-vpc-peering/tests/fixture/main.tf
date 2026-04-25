variable "project_id" {
  type = string
}

# Création de deux réseaux via ton module gcp-networks
module "networks" {
  source     = "../../../gcp-networks"
  project_id = var.project_id
  networks = {
    "net-a" = {
      network = { name = "vpc-a", subnets = [{ name = "sub-a", cidr = "10.0.1.0/24", region = "europe-west9" }] }
    },
    "net-b" = {
      network = { name = "vpc-b", subnets = [{ name = "sub-b", cidr = "10.0.2.0/24", region = "europe-west9" }] }
    }
  }
}

# Appel du module VPC Peering à tester
module "peering" {
  source             = "../../"
  local_network_id   = "projects/${var.project_id}/global/networks/vpc-a"
  local_network_name = "vpc-a"
  peer_network_id    = "projects/${var.project_id}/global/networks/vpc-b"
  peer_network_name  = "vpc-b"

  export_custom_routes = true
  import_custom_routes = true

  depends_on = [module.networks]
}
