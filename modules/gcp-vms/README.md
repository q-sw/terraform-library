# Module : GCP VMs

Ce module permet de provisionner des instances GCE.

## Caractéristiques Clés

- **Multi-NIC (RFC-001)** : Supporte plusieurs interfaces réseau par VM.
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
    }
  }
}
```

## Entrées (Inputs)

| Nom | Description | Type | Défaut |
| :--- | :--- | :--- | :--- |
| `project_id` | L'ID du projet GCP cible. | `string` | n/a |
| `vms` | Map d'instances à provisionner avec configuration multi-NIC. | `map` | `{}` |

## Sorties (Outputs)

| Nom | Description |
| :--- | :--- |
| `instance_ids` | Map des IDs uniques des instances GCE. |
| `instance_ips` | Détails des interfaces réseau et des IPs affectées. |
