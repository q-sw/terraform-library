output "primary_csr" {
  description = "La CSR à copier et à soumettre à votre Root CA externe pour signature."
  value       = module.vault_pki_delegated.primary_csr
}

output "secondary_paths" {
  description = "Chemins d'accès aux backends PKI secondaires configurés."
  value       = module.vault_pki_delegated.secondary_paths
}

output "policy_name" {
  description = "Nom de la politique Vault configurée pour la PKI."
  value       = module.vault_pki_delegated.policy_name
}
