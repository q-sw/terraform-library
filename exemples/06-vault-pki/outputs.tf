output "primary_path" {
  description = "Chemin d'accès au backend PKI de la CA primaire."
  value       = module.vault_pki.primary_path
}

output "secondary_paths" {
  description = "Chemin d'accès aux backends PKI secondaires configurés."
  value       = module.vault_pki.secondary_paths
}

output "policy_name" {
  description = "Nom de la politique Vault configurée pour la PKI."
  value       = module.vault_pki.policy_name
}
