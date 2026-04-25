locals {
  flattened_subnets = flatten([
    for network_key, network_value in var.networks : [
      for subnet in network_value.network.subnets : {
        network_key  = network_key
        network_name = network_value.network.name
        subnet_name  = subnet.name
        cidr         = subnet.cidr
        region       = subnet.region
        stack_type   = subnet.stack_type
      }
    ]
  ])
  flattened_firewall_rules = flatten([
    for network_key, network_value in var.networks : [
      for rule in network_value.network.firewall_rules : {
        network_key   = network_key
        name          = rule.name
        protocol      = rule.protocol
        ports         = rule.ports
        source_ranges = rule.from_sources
      }
    ]
  ])
}

resource "google_project_service" "api" {
  project            = var.project_id
  service            = "compute.googleapis.com"
  disable_on_destroy = true
}

resource "google_compute_network" "vpcs" {
  for_each                = var.networks
  project                 = var.project_id
  name                    = each.value.network.name
  auto_create_subnetworks = false

  # Support IPv6 ULA (Souveraineté)
  enable_ula_internal_ipv6 = each.value.network.enable_ipv6

  depends_on = [google_project_service.api]
}

resource "google_compute_router" "routers" {
  for_each = var.networks
  project  = var.project_id
  name     = "rt-${each.value.network.name}"
  network  = google_compute_network.vpcs[each.key].id
  region   = var.default_region
  bgp {
    asn = each.value.network.asn
  }
}

resource "google_compute_router_nat" "nat" {
  for_each                           = var.networks
  project                            = var.project_id
  name                               = "nat-${each.value.network.name}"
  router                             = google_compute_router.routers[each.key].name
  region                             = var.default_region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_subnetwork" "subnets" {
  for_each = {
    for subnet in local.flattened_subnets : "${subnet.network_key}.${subnet.subnet_name}" => subnet
  }

  project          = var.project_id
  name             = each.value.subnet_name
  ip_cidr_range    = each.value.cidr
  region           = each.value.region
  network          = google_compute_network.vpcs[each.value.network_key].id
  stack_type       = each.value.stack_type
  ipv6_access_type = each.value.stack_type == "IPV4_IPV6" ? "INTERNAL" : null
}

resource "google_compute_firewall" "firewall_rules" {
  for_each = {
    for rule in local.flattened_firewall_rules : "${rule.network_key}.${rule.name}" => rule
  }
  project = var.project_id
  name    = each.value.name
  network = google_compute_network.vpcs[each.value.network_key].id
  allow {
    protocol = each.value.protocol
    ports    = each.value.ports
  }
  source_ranges = each.value.source_ranges
}
