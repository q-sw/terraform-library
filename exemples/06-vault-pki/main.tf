module "vault_pki" {
  source   = "../../modules/vault-pki"
  pki_mode = "internal"

  primary_ca = {
    name         = "pki-root"
    description  = "Root CA d'entreprise pour les environnements de dev/test"
    common_name  = "Dev Corporate Root CA"
    organization = "Corporate Dev"
    ou           = "IT Security"
    country      = "FR"
    locality     = "Paris"
    province     = "IDF"
    key_type     = "ec"
    key_bits     = "256"
    ttl          = "315360000s" # 10 ans
  }

  secondary_cas = {
    "pki-sub-web" = {
      description     = "Intermediate CA pour la signature de certificats web internes"
      common_name     = "Corporate Web Intermediate CA"
      organization    = "Corporate Dev"
      ou              = "Web Hosting"
      country         = "FR"
      locality        = "Paris"
      province        = "IDF"
      key_type        = "ec"
      key_bits        = "256"
      max_ttl         = "31536000s" # 1 an
      role_name       = "web-servers"
      allowed_domains = ["dev.corp.lan", "localhost"]
    },
    "pki-sub-db" = {
      description     = "Intermediate CA pour la signature de certificats de base de données"
      common_name     = "Corporate Database Intermediate CA"
      organization    = "Corporate Dev"
      ou              = "DB Admin"
      country         = "FR"
      locality        = "Paris"
      province        = "IDF"
      key_type        = "ec"
      key_bits        = "256"
      max_ttl         = "63072000s" # 2 ans
      role_name       = "db-servers"
      allowed_domains = ["db.dev.corp.lan"]
    }
  }
}
