resource "google_project_service" "api" {
  for_each           = toset(var.apis)
  project            = var.project_id
  service            = each.key
  disable_on_destroy = true
}
