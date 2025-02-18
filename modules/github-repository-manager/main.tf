resource "github_repository" "repository" {
  name        = var.repository_name
  description = var.repository_description

  visibility         = var.visibility_mode
  auto_init          = false
  gitignore_template = var.gitignore_template

  # Sécurité automatique pour les dépôts publics
  #  vulnerability_alerts = var.visibility_mode == "public" ? true : false
  #
  #  dynamic "security_and_analysis" {
  #    for_each = var.visibility_mode == "public" ? [1] : []
  #    content {
  #      secret_scanning {
  #        status = "enabled"
  #      }
  #      secret_scanning_push_protection {
  #        status = "enabled"
  #      }
  #    }
  #  }
}

resource "github_branch_protection" "master" {
  count               = var.visibility_mode == "public" ? 1 : 0
  repository_id       = github_repository.repository.node_id
  pattern             = "main"
  allows_deletions    = false
  allows_force_pushes = false

  enforce_admins = var.enforce_admins
  required_pull_request_reviews {
    required_approving_review_count = var.enforce_admins ? 1 : 0
  }
}

resource "github_branch" "development" {
  repository    = github_repository.repository.name
  branch        = "dev"
  source_branch = github_repository.repository.default_branch
}

resource "github_branch_protection" "development" {
  count               = var.visibility_mode == "public" ? 1 : 0
  repository_id       = github_repository.repository.node_id
  pattern             = "dev"
  allows_deletions    = false
  allows_force_pushes = false

  enforce_admins = var.enforce_admins

  required_pull_request_reviews {
    required_approving_review_count = var.enforce_admins ? 1 : 0
  }
}
