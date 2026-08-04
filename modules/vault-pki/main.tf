locals {
  primary_cert = var.pki_mode == "internal" ? (length(vault_pki_secret_backend_root_cert.internal_root) > 0 ? vault_pki_secret_backend_root_cert.internal_root[0].certificate : null) : var.delegated_signed_cert
}

# 1. Montage du backend PKI pour la CA Primaire
resource "vault_mount" "primary" {
  path                      = var.primary_ca.name
  type                      = "pki"
  description               = var.primary_ca.description
  default_lease_ttl_seconds = 157700000 # 5 ans
  max_lease_ttl_seconds     = 315400000 # 10 ans
}

# 2. Génération de la Root CA en mode Interne
resource "vault_pki_secret_backend_root_cert" "internal_root" {
  count        = var.pki_mode == "internal" ? 1 : 0
  backend      = vault_mount.primary.path
  type         = "internal"
  common_name  = var.primary_ca.common_name
  ou           = var.primary_ca.ou
  organization = var.primary_ca.organization
  country      = var.primary_ca.country
  locality     = var.primary_ca.locality
  province     = var.primary_ca.province
  key_type     = var.primary_ca.key_type
  key_bits     = var.primary_ca.key_bits
  ttl          = var.primary_ca.ttl
}

# 3. Génération de la CSR en mode Delegated (Externe)
resource "vault_pki_secret_backend_intermediate_cert_request" "delegated_csr" {
  count        = var.pki_mode == "delegated" ? 1 : 0
  backend      = vault_mount.primary.path
  type         = "internal"
  common_name  = var.primary_ca.common_name
  ou           = var.primary_ca.ou
  organization = var.primary_ca.organization
  country      = var.primary_ca.country
  locality     = var.primary_ca.locality
  province     = var.primary_ca.province
  key_type     = var.primary_ca.key_type
  key_bits     = var.primary_ca.key_bits
}

# 4. Import du certificat signé de la CA primaire (si mode Delegated)
resource "vault_pki_secret_backend_intermediate_set_signed" "delegated_import" {
  count       = var.pki_mode == "delegated" && var.delegated_signed_cert != null ? 1 : 0
  backend     = vault_mount.primary.path
  certificate = var.delegated_signed_cert
}

# 5. Montage des backends PKI pour les CAs Secondaires (Sub CAs)
resource "vault_mount" "secondaries" {
  for_each                  = var.secondary_cas
  path                      = each.key
  type                      = "pki"
  description               = each.value.description
  default_lease_ttl_seconds = 3600     # 1 heure par défaut pour les certificats terminaux
  max_lease_ttl_seconds     = 31536000 # 1 an maximum
}

# 6. Génération de la CSR pour les CAs Secondaires
resource "vault_pki_secret_backend_intermediate_cert_request" "secondaries" {
  for_each     = var.secondary_cas
  backend      = vault_mount.secondaries[each.key].path
  type         = "internal"
  common_name  = each.value.common_name
  ou           = each.value.ou
  organization = each.value.organization
  country      = each.value.country
  locality     = each.value.locality
  province     = each.value.province
  key_type     = each.value.key_type
  key_bits     = each.value.key_bits
}

# 7. Signature des CSRs des CAs Secondaires par la CA Primaire
resource "vault_pki_secret_backend_root_sign_intermediate" "secondaries" {
  for_each             = var.secondary_cas
  backend              = vault_mount.primary.path
  csr                  = vault_pki_secret_backend_intermediate_cert_request.secondaries[each.key].csr
  common_name          = each.value.common_name
  exclude_cn_from_sans = true
  ou                   = each.value.ou
  organization         = each.value.organization
  country              = each.value.country
  locality             = each.value.locality
  province             = each.value.province
  max_path_length      = 1
  ttl                  = each.value.max_ttl

  # S'assurer que si on est en mode delegated, l'import a bien eu lieu avant de signer
  depends_on = [
    vault_pki_secret_backend_intermediate_set_signed.delegated_import
  ]
}

# 8. Import du certificat secondaire signé dans son backend respectif
resource "vault_pki_secret_backend_intermediate_set_signed" "secondaries" {
  for_each = var.secondary_cas
  backend  = vault_mount.secondaries[each.key].path
  certificate = (
    local.primary_cert != null ?
    "${vault_pki_secret_backend_root_sign_intermediate.secondaries[each.key].certificate}\n${local.primary_cert}" :
    vault_pki_secret_backend_root_sign_intermediate.secondaries[each.key].certificate
  )
}

# 9. Création des rôles PKI associés pour l'émission de certificats finaux
resource "vault_pki_secret_backend_role" "roles" {
  for_each                    = var.secondary_cas
  backend                     = vault_mount.secondaries[each.key].path
  name                        = each.value.role_name
  ttl                         = each.value.max_ttl
  allowed_domains             = each.value.allowed_domains
  allow_subdomains            = true
  allow_localhost             = true
  allow_wildcard_certificates = true
  key_type                    = each.value.key_type
  key_bits                    = each.value.key_bits
  enforce_hostnames           = true
}

# 10. Génération de la politique Vault pour accéder à la PKI
resource "vault_policy" "pki" {
  name = "pki-policy"

  policy = <<EOT
# Accès à la CA primaire
path "${vault_mount.primary.path}*" {
  capabilities = ["read", "list", "create", "update"]
}

# Accès aux CAs secondaires et à l'émission de certificats
%{for path, ca in var.secondary_cas~}
path "${path}*" {
  capabilities = ["read", "list", "create", "update"]
}
%{endfor~}
EOT
}
