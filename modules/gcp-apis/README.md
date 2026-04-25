# Module : GCP APIs (SRE ISR-Nix)

Ce module permet d'activer de manière granulaire et déclarative les APIs Google Cloud Platform nécessaires pour le projet.

## Caractéristiques Clés

- **Idempotence** : Utilise `for_each` pour garantir que chaque API est gérée comme une ressource unique.
- **Sécurité** : `disable_on_destroy` est positionné à `false` par défaut pour éviter de couper accidentellement des services lors de la destruction d'une partie de la pile Terraform.

## Utilisation

```hcl
module "apis" {
  source     = "../../modules/gcp-apis"
  project_id = "my-project-id"
  
  apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com"
  ]
}
```

## Entrées (Inputs)

| Nom | Description | Type | Défaut | Obligatoire |
| :--- | :--- | :--- | :--- | :--- |
| `project_id` | L'ID du projet GCP cible. | `string` | n/a | Oui |
| `apis` | Liste des services API Google à activer. | `list(string)` | `[]` | Non |

## Sorties (Outputs)

| Nom | Description |
| :--- | :--- |
| `apis_enable` | Liste des IDs des services APIs effectivement activés. |
