variable "signed_cert_pem" {
  type        = string
  description = "Le certificat signé (PEM ou bundle) retourné par l'autorité racine externe après signature de la CSR."
  default     = null # Reste à null lors du premier run pour générer la CSR
}
