output "primary_path" {
  description = "Chemin d'accès au backend PKI de la CA primaire."
  value       = vault_mount.primary.path
}

output "primary_csr" {
  description = "La CSR générée pour la CA primaire intermédiaire (si pki_mode = 'delegated')."
  value       = var.pki_mode == "delegated" ? (length(vault_pki_secret_backend_intermediate_cert_request.delegated_csr) > 0 ? vault_pki_secret_backend_intermediate_cert_request.delegated_csr[0].csr : null) : null
}

output "secondary_paths" {
  description = "Chemin d'accès aux backends PKI secondaires configurés."
  value       = { for k, v in vault_mount.secondaries : k => v.path }
}

output "policy_name" {
  description = "Nom de la politique Vault configurée pour la PKI."
  value       = vault_policy.pki.name
}
