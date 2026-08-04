# Workflow du mode Delegated (CA signée de manière externe) :
#
# Étape 1 : Lancer un premier 'terraform apply' sans fournir de certificat signé.
#           Terraform va monter le backend primaire et générer la CSR (Certificate Signing Request).
#
# Étape 2 : Récupérer la CSR depuis l'output 'primary_csr' et la faire signer
#           par votre Root CA d'entreprise (en dehors de Terraform).
#
# Étape 3 : Fournir le certificat signé obtenu via la variable 'signed_cert_pem'
#           (ou via un fichier tfvars) et relancer 'terraform apply'.
#           Le module va importer le certificat, puis créer et signer les CAs secondaires.

module "vault_pki_delegated" {
  source   = "../../modules/vault-pki"
  pki_mode = "delegated"

  primary_ca = {
    name         = "pki-root-delegated"
    description  = "CA intermédiaire primaire signée extérieurement"
    common_name  = "Corporate Intermediate Primary CA"
    organization = "Corporate Dev"
    ou           = "IT Security"
    country      = "FR"
    locality     = "Paris"
    province     = "IDF"
    key_type     = "ec"
    key_bits     = "256"
  }

  # Injection du certificat une fois qu'il a été signé à l'étape 2
  delegated_signed_cert = var.signed_cert_pem

  secondary_cas = {
    "pki-sub-web-delegated" = {
      description     = "CA intermédiaire secondaire pour serveurs Web"
      common_name     = "Corporate Web Intermediate CA"
      organization    = "Corporate Dev"
      ou              = "Web Hosting"
      country         = "FR"
      locality        = "Paris"
      province        = "IDF"
      key_type        = "ec"
      key_bits        = "256"
      max_ttl         = "31536000s" # 1 an
      role_name       = "web-servers-delegated"
      allowed_domains = ["dev.corp.lan"]
    }
  }
}
