terraform {
  required_version = ">= 1.5.0"

  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">= 3.0.0"
    }
  }
}

provider "vault" {
  # L'adresse et le token de Vault sont configurés via les variables d'environnement
  # VAULT_ADDR et VAULT_TOKEN
}
