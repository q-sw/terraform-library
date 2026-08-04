# Module : Vault PKI

Ce module permet de configurer une infrastructure de clés publiques (PKI) hiérarchique basée sur HashiCorp Vault. Il prend en charge la création d'une autorité de certification (CA) primaire et d'autorités secondaires (Sub CAs) avec des rôles et politiques d'accès.

## Caractéristiques Clés

- **Flexibilité** : Supporte le mode `internal` (la Root CA est générée directement par Vault) et le mode `delegated` (Vault génère une CSR qui est signée à l'extérieur).
- **Modernité** : Utilise des structures dynamiques et `for_each` pour provisionner un nombre arbitraire de CAs secondaires de manière robuste.
- **Politiques intégrées** : Génère automatiquement une politique Vault (`pki-policy`) accordant les privilèges requis sur les chemins de la PKI configurée.

## Utilisation

### Mode Interne (Root CA générée par Vault)

```hcl
module "vault_pki" {
  source   = "../../modules/vault-pki"
  pki_mode = "internal"

  primary_ca = {
    name         = "pki-root"
    description  = "Root CA d'entreprise"
    common_name  = "Company Root CA"
    organization = "My Company"
    country      = "FR"
  }

  secondary_cas = {
    "pki-sub-web" = {
      description     = "Intermediate CA pour les serveurs Web"
      common_name     = "Company Web Sub CA"
      organization    = "My Company"
      country         = "FR"
      role_name       = "web-servers"
      allowed_domains = ["company.lan", "localhost"]
    }
  }
}
```

## Entrées (Inputs)

| Nom | Description | Type | Défaut | Obligatoire |
| :--- | :--- | :--- | :--- | :--- |
| `pki_mode` | Mode de la PKI : `internal` (générée par Vault) ou `delegated` (génère une CSR). | `string` | `"internal"` | Non |
| `primary_ca` | Configuration de la CA primaire (Root ou intermédiaire primaire). | `object` | n/a | Oui |
| `delegated_signed_cert` | Le certificat signé à importer pour la CA primaire en mode `delegated`. | `string` | `null` | Non |
| `secondary_cas` | Map des autorités secondaires (Sub CAs) à créer et signer via la CA primaire. | `map` | `{}` | Non |

## Sorties (Outputs)

| Nom | Description |
| :--- | :--- |
| `primary_path` | Chemin d'accès au backend PKI de la CA primaire. |
| `primary_csr` | La CSR générée pour la CA primaire (en mode `delegated`). |
| `secondary_paths` | Map associant les CAs secondaires à leurs chemins de montage respectifs. |
| `policy_name` | Nom de la politique Vault générée pour accéder à la PKI. |
