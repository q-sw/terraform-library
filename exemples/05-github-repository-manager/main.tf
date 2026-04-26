
module "github_repository" {
  source = "../modules/github-repository-manager"

  repository_name        = "my-awesome-project"
  repository_description = "An awesome project built with Terraform"
  visibility_mode        = "private"
  gitignore_template     = "Terraform"
  enforce_admins         = true
}
