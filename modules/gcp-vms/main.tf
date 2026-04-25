resource "google_compute_instance" "instances" {
  for_each = var.vms
  project  = var.project_id
  name     = each.value.name

  machine_type = each.value.machine_type
  zone         = each.value.zone

  boot_disk {
    initialize_params {
      image = each.value.image
      size  = each.value.boot_disk_size_gb
      type  = "pd-balanced"
    }
  }

  dynamic "network_interface" {
    for_each = each.value.network_interfaces
    content {
      subnetwork = network_interface.value.subnetwork_id
      network_ip = network_interface.value.network_ip
      nic_type   = network_interface.value.nic_type
      stack_type = network_interface.value.stack_type

      # Forcer l'IPv6 interne (Internal Access Type) si stack dual
      # ipv6_access_type = network_interface.value.stack_type == "IPV4_IPV6" ? "INTERNAL" : null
    }
  }

  tags     = each.value.tags
  metadata = each.value.metadata

  # Sécurité : Bloquer l'IP forwarding par défaut (sauf si configuré via metadata)
  can_ip_forward = contains(each.value.tags, "router") ? true : false

  service_account {
    scopes = ["cloud-platform"]
  }

  lifecycle {
    ignore_changes = [
      metadata["ssh-keys"],
    ]
  }
}
