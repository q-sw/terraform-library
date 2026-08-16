# Module : GCP VMs

Ce module permet de provisionner des instances GCE.

## Caractéristiques Clés

- **Multi-NIC** : Supporte plusieurs interfaces réseau par VM.
- **Sécurité** : `can_ip_forward` est géré par tag, et le cycle de vie ignore les clés SSH injectées après le bootstrap.

## Utilisation

```hcl
module "vms" {
  source     = "../../modules/gcp-vms"
  project_id = "my-project-id"

  vms = {
    "hub-mgmt" = {
      name         = "hub-mgmt-01"
      machine_type = "e2-standard-4"
      zone         = "europe-west9-a"
      image        = "nixos-custom-image-v1"
      boot_disk_size_gb = 50
      network_interfaces = [
        { subnetwork_id = "sb-dc1-admin", nic_type = "VIRTIO_NET", stack_type = "IPV4_ONLY" },
        { subnetwork_id = "sb-dc1-mgmt",  nic_type = "GVNIC",      stack_type = "IPV4_IPV6" }
      ]
      tags     = ["hub", "management"]
      metadata = { "environment" = "poc" }
      nested_virt = true # Optionnel, false par défaut
    }
  }
}
```

## Entrées (Inputs)

| Nom          | Description                                                  | Type     | Défaut |
| :----------- | :----------------------------------------------------------- | :------- | :----- |
| `project_id` | L'ID du projet GCP cible.                                    | `string` | n/a    |
| `vms`        | Map d'instances à provisionner avec configuration multi-NIC. | `map`    | `{}`   |

### Structure de l'objet `vms`

Chaque instance définie dans la map `vms` accepte les attributs suivants :

| Attribut | Description | Type | Défaut |
| :--- | :--- | :--- | :--- |
| `name` | Nom de l'instance GCE. | `string` | n/a |
| `machine_type` | Type de machine (ex: `e2-standard-4`). | `string` | n/a |
| `zone` | Zone GCP où provisionner la VM. | `string` | n/a |
| `image` | Image disque de démarrage (nom ou self-link). | `string` | n/a |
| `boot_disk_size_gb` | Taille du disque de démarrage en Go. | `number` | n/a |
| `network_interfaces` | Liste de configurations d'interfaces réseau (multi-NIC). | `list(object)` | n/a |
| `tags` | Liste de tags réseau à associer à la VM. | `list(string)` | n/a |
| `metadata` | Métadonnées (ex: clés SSH, variables d'init). | `map(string)` | n/a |
| `nested_virt` | Activer la virtualisation imbriquée (nested virtualization). | `bool` | `false` |

## Sorties (Outputs)

| Nom            | Description                                         |
| :------------- | :-------------------------------------------------- |
| `instance_ids` | Map des IDs uniques des instances GCE.              |
| `instance_ips` | Détails des interfaces réseau et des IPs affectées. |
