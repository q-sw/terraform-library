resource "google_compute_network_peering" "peering_local_to_peer" {
  name                                = "peering-${var.local_network_name}-to-${var.peer_network_name}"
  network                             = var.local_network_id
  peer_network                        = var.peer_network_id
  export_custom_routes                = var.export_custom_routes
  import_custom_routes                = var.import_custom_routes
  export_subnet_routes_with_public_ip = var.export_subnet_routes_with_public_ip
  import_subnet_routes_with_public_ip = var.import_subnet_routes_with_public_ip
}

resource "google_compute_network_peering" "peering_peer_to_local" {
  name                                = "peering-${var.peer_network_name}-to-${var.local_network_name}"
  network                             = var.peer_network_id
  peer_network                        = var.local_network_id
  export_custom_routes                = var.export_custom_routes
  import_custom_routes                = var.import_custom_routes
  export_subnet_routes_with_public_ip = var.export_subnet_routes_with_public_ip
  import_subnet_routes_with_public_ip = var.import_subnet_routes_with_public_ip

  depends_on = [google_compute_network_peering.peering_local_to_peer]
}
