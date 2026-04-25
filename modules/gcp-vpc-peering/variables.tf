variable "local_network_id" {
  type        = string
  description = "The ID of the local VPC network."
  default     = null
}

variable "local_network_name" {
  type        = string
  description = "The name of the local VPC network."
  default     = null
}

variable "peer_network_id" {
  type        = string
  description = "The ID of the peer VPC network."
  default     = null
}

variable "peer_network_name" {
  type        = string
  description = "The name of the peer VPC network."
  default     = null
}

variable "export_custom_routes" {
  type        = bool
  description = "Whether to export custom routes to the peer network."
  default     = true
}

variable "import_custom_routes" {
  type        = bool
  description = "Whether to import custom routes from the peer network."
  default     = true
}

variable "export_subnet_routes_with_public_ip" {
  type        = bool
  description = "Whether to export subnet routes with public IP to the peer network."
  default     = true
}

variable "import_subnet_routes_with_public_ip" {
  type        = bool
  description = "Whether to import subnet routes with public IP from the peer network."
  default     = true
}
