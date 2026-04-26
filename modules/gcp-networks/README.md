# Module : GCP Networks

Ce module permet de provisionner des VPC, des sous-réseaux IPv4/IPv6 dual-stack, des routeurs Cloud NAT pour l'accès Internet et des règles de firewall.

## Caractéristiques Clés

- **Multi-VPC** : Capacité à créer plusieurs réseaux VPC via une map `networks`.
- **Structure Aplatie (Flattening)** : Supporte plusieurs sous-réseaux et règles de firewall par VPC.
- **NAT Gateway** : Provisionne un routeur NAT par VPC pour permettre aux nœuds de télécharger des mises à jour sans IP publique.

## Utilisation

```hcl
module "networks" {
  source     = "../../modules/gcp-networks"
  project_id = "my-project-id"

  networks = {
    "dc1" = {
      network = {
        name = "vpc-dc1"
        subnets = [
          { name = "sb-admin", cidr = "10.10.0.0/24", region = "europe-west9" }
        ]
        firewall_rules = [
          { name = "fw-allow-ssh", protocol = "tcp", ports = ["22"], from_sources = ["0.0.0.0/0"] }
        ]
      }
    }
  }
}
```

## Entrées (Inputs)

| Nom | Description | Type | Défaut |
| :--- | :--- | :--- | :--- |
| `project_id` | L'ID du projet GCP cible. | `string` | n/a |
| `default_region` | Région par défaut pour les routeurs et NAT. | `string` | `europe-west9` |
| `networks` | Map complexe décrivant la topologie réseau. | `map` | n/a |

## Sorties (Outputs)

| Nom | Description |
| :--- | :--- |
| `network_ids` | Map des IDs des VPC créés. |
| `subnet_ids` | Map des IDs des sous-réseaux créés (clé: `vpc.subnet`). |
