// Configure the Google Cloud provider
provider "google" {
    version     = "v2.14.0"
    credentials = "${file("${var.sa}")}"
    project     = "${var.gcp_project_id}"
    region      = "${var.gcp_region}"
}

provider "kubernetes" {
    version = "v1.9.0"
    host = "https://${google_container_cluster.primary.endpoint}"

    username = "${google_container_cluster.primary.master_auth.0.username}"
    password = "${google_container_cluster.primary.master_auth.0.password}"

    client_certificate     = "${base64decode(google_container_cluster.primary.master_auth.0.client_certificate)}"
    client_key             = "${base64decode(google_container_cluster.primary.master_auth.0.client_key)}"
    cluster_ca_certificate = "${base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)}"
}

provider "helm" {
    version = "0.10.2"
    tiller_image = "gcr.io/kubernetes-helm/tiller:v2.14.3"
    service_account = "tiller"
    kubernetes {
        host = "https://${google_container_cluster.primary.endpoint}"
        username = "${google_container_cluster.primary.master_auth.0.username}"
        password = "${google_container_cluster.primary.master_auth.0.password}"
        cluster_ca_certificate = "${base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)}"
        client_key = "${base64decode(google_container_cluster.primary.master_auth.0.client_key)}"
        client_certificate = "${base64decode(google_container_cluster.primary.master_auth.0.client_certificate)}"
    }
}