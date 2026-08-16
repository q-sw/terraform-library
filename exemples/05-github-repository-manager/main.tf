
module "github_repository" {
  source = "../modules/github-repository-manager"

  repository_name        = "my-awesome-project"
  repository_description = "An awesome project built with Terraform"
  visibility_mode        = "public"
  gitignore_template     = "Terraform"
  enforce_admins         = true

  # Paramètres pour projet solo (pas de blocage sur l'approval des PR)
  require_pull_request            = true
  required_approving_review_count = 0
}

