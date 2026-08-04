variable "pki_mode" {
  type        = string
  description = "Mode de fonctionnement de la PKI : 'internal' (Root CA générée en interne) ou 'delegated' (génère une CSR à signer extérieurement)."
  default     = "internal"

  validation {
    condition     = contains(["internal", "delegated"], var.pki_mode)
    error_message = "La valeur de pki_mode doit être 'internal' ou 'delegated'."
  }
}

variable "primary_ca" {
  type = object({
    name         = string
    description  = string
    common_name  = string
    ou           = optional(string)
    organization = optional(string)
    country      = optional(string)
    locality     = optional(string)
    province     = optional(string)
    key_type     = optional(string, "ec")
    key_bits     = optional(string, "256")
    ttl          = optional(string, "315360000s") # 10 ans
  })
  description = "Configuration de la CA primaire (Root ou intermédiaire primaire)."
}

variable "delegated_signed_cert" {
  type        = string
  description = "Le certificat signé (PEM ou bundle) à importer pour la CA primaire en mode 'delegated'."
  default     = null
  sensitive   = true
}

variable "secondary_cas" {
  type = map(object({
    description     = string
    common_name     = string
    ou              = optional(string)
    organization    = optional(string)
    country         = optional(string)
    locality        = optional(string)
    province        = optional(string)
    key_type        = optional(string, "ec")
    key_bits        = optional(string, "256")
    max_ttl         = optional(string, "31536000s") # 1 an
    role_name       = string
    allowed_domains = list(string)
  }))
  description = "Map des autorités secondaires (Sub CAs) à créer et signer via la CA primaire."
  default     = {}
}
