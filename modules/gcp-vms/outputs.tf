output "instance_ids" {
  value = { for k, v in google_compute_instance.instances : k => v.instance_id }
}

output "instance_ips" {
  value = { for k, v in google_compute_instance.instances : k => {
    network_interface = v.network_interface
  }}
}
