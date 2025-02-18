resource "github_repository" "repository" {
  name        = var.repository_name
  description = var.repository_description

  visibility = var.visibility_mode
  auto_init = true
  gitignore_template = var.gitignore_template
}


resource "github_branch_protection" "master"{
  count = var.visibility_mode == "public" ? 1 : 0
  repository_id = github_repository.repository.name
  pattern          = "main"
  allows_deletions = false
  allows_force_pushes = false
  required_pull_request_reviews {
    required_approving_review_count=1
  }
}

resource "github_branch" "development" {
  repository = github_repository.repository.name
  branch     = "dev"
  source_branch = github_repository.repository.default_branch
}

resource "github_branch_protection" "development"{
  count = var.visibility_mode == "public" ? 1 : 0
  repository_id = github_repository.repository.name
  pattern          = "dev"
  allows_deletions = false
  allows_force_pushes = false
  required_pull_request_reviews {
    required_approving_review_count=1
  }
}
