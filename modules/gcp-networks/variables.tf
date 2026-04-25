variable "project_id" {
  type        = string
  description = "The GCP project ID where the network resources will be created."
  default     = null
}

variable "default_region" {
  type        = string
  description = "The default GCP region used for regional resources like Cloud Router and NAT."
  default     = "europe-west9"
}

variable "networks" {
  type = map(object({
    network = object({
      name        = string
      enable_ipv6 = bool
      asn         = number
      subnets = list(object({
        name       = string
        cidr       = string
        region     = string
        stack_type = string # "IPV4_ONLY" or "IPV4_IPV6"
      }))
      firewall_rules = list(object({
        name         = string
        protocol     = string
        ports        = list(string)
        from_sources = list(string)
      }))
    })
  }))
  description = "A complex map defining the VPC topology, including subnets (IPv4/IPv6 Dual-Stack) and firewall rules."
  default     = {}
}
