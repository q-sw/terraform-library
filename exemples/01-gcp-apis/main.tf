module "gcp_apis" {
  source     = "../modules/gcp-apis"
  project_id = var.project_id
  apis = [
    "compute.googleapis.com",
    "storage.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]
}
