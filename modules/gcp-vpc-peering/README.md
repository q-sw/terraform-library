# Module : GCP VPC Peering (SRE ISR-Nix)

Ce module établit une liaison bidirectionnelle sécurisée entre deux réseaux VPC sur Google Cloud Platform. Il est utilisé pour simuler le backbone MPLS entre différents centres de données (DC1 <-> DC2).

## Caractéristiques

- **Bidirectionnel** : Crée automatiquement les deux ressources de peering nécessaires.
- **Routage Personnalisé** : Gère l'export et l'import des routes personnalisées (utile pour le routage BGP Cilium).
- **Dépendance explicite** : Garantit que le premier lien est initié avant le second pour éviter les erreurs de state dans Terraform.

## Utilisation

```hcl
module "peering_dc1_dc2" {
  source           = "../../modules/gcp-vpc-peering"
  peering_name     = "dc1-to-dc2"
  local_network_id = module.networks.network_ids["dc1"]
  peer_network_id  = module.networks.network_ids["dc2"]
}
```
