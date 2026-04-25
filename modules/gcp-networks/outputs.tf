output "network_ids" {
  value = { for k, v in google_compute_network.vpcs : k => v.id }
}

output "subnet_ids" {
  value = { for k, v in google_compute_subnetwork.subnets : k => v.id }
}
