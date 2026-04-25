variable "project_id" {
  type        = string
  description = "The GCP project ID where APIs will be enabled."
  default     = null
}

variable "apis" {
  type        = list(string)
  description = "List of GCP APIs to enable (e.g., compute.googleapis.com)."
  default     = []
}
