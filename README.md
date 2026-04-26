# terraform-library

Library de modules Terraform réutilisables pour construire et opérer des environnements cloud as code.

## Objectif

Ce dépôt contient des modules Terraform pensés pour construire de infrastructure de production ou de test:
- **Multi-DC(Region)** : Architecture distribuée sur plusieurs Regions
- **Idempotence** : Tous les modules sont idempotents (utilisent `for_each`, `depends_on`)
- **Sécurité** : Principe du moindre privilège intégré par défaut
- **Dual-stack** : Support natif IPv4/IPv6

## Comment utiliser ce dépôt

### Prérequis

- Nix ( flakes activés)
- Terraform >= 1.0
- Provider GCP (Google Cloud Platform)
- Provider GitHub (pour module `github-repository-manager`)

### Utilisation

1. **Cloner le dépôt** :
   ```bash
   git clone https://github.com/votre-org/terraform-library.git
   ```

2. **Entrer dans l'environnement de développement** (inclus Terratest):
   ```bash
   cd terraform-library
   nix develop
   ```

3. **Appeler un module** dans ваш :
   ```hcl
   module "mon_module" {
     source = "./terraform-library/modules/<module_name>"
     # ... variables
   }
   ```

4. **Initialiser** :
   ```bash
   terraform init
   ```

### Tester un module

Chaque module contient un dossier `tests/` avec des tests Terratest :
```bash
cd modules/<module_name>/tests
go test -v .
```

## Modules disponibles

| Module | Description | Chemin |
|--------|-------------|--------|
| `gcp-apis` | Activation granulaire et déclarative des APIs GCP | `modules/gcp-apis` |
| `gcp-networks` | VPCs, sous-réseaux IPv4/IPv6 dual-stack, NAT, firewall | `modules/gcp-networks` |
| `gcp-vpc-peering` | Liaison bidirectionnelle sécurisée entre deux VPCs (simule backbone MPLS) | `modules/gcp-vpc-peering` |
| `gcp-vms` | Provisionnement de VMs GCE multi-NIC | `modules/gcp-vms` |
| `github-repository-manager` | Gestion automatisée des dépôt GitHub (repo, branches, protections) | `modules/github-repository-manager` |

## Structure

```
terraform-library/
├── modules/
│   ├── gcp-apis/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── versions.tf
│   │   ├── README.md
│   │   └── tests/
│   ├── gcp-networks/
│   │   └── ...
│   ├── gcp-vpc-peering/
│   │   └── ...
│   ├── gcp-vms/
│   │   └── ...
│   └── github-repository-manager/
│       └── ...
├── flake.nix
└── README.md
```
