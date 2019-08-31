variable "gcp_project_id" {
  description = "The name of the GCP Project where all resources will be launched."
  default = "xxxx"
}

variable "sa" {
  description = "The name of the GCP Project where all resources will be launched."
  default = "sa/sa.json"
}

variable "gcp_region" {
  description = "The region in which all GCP resources will be launched."
  default = "asia-southeast1"
}

variable "replicaCount" {
  description = "wordpress replicaCount"
  default = "1"
}

output "Done! The blog can be accessed at" {
  value = "http://${kubernetes_service.wordpress.load_balancer_ingress.0.ip}/"
}
