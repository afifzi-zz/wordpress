resource "google_container_cluster" "primary" {
    name               = "test-cluster"
    location           = "asia-southeast1"
    initial_node_count = 1

    master_auth {
        username ="admin"
        password ="test1234567891011121314"
        client_certificate_config {
            issue_client_certificate = false
        }
    }
    node_config {
        oauth_scopes = [
            "https://www.googleapis.com/auth/logging.write",
            "https://www.googleapis.com/auth/monitoring",
        ]
    }

    timeouts {
        create = "30m"
        update = "40m"
    }
}


resource "kubernetes_service_account" "tiller" {
    metadata {
        name = "tiller"
        namespace = "kube-system"
    }
    secret {
        name = "${kubernetes_secret.tiller.metadata.0.name}"
    }
    depends_on = ["kubernetes_secret.tiller"]
}

resource "kubernetes_secret" "tiller" {
    metadata {
        name = "tiller"
        namespace = "kube-system"
    }
}

resource "kubernetes_cluster_role_binding" "tiller" {
    metadata {
        name = "tiller"
    }
    role_ref {
        api_group = "rbac.authorization.k8s.io"
        kind      = "ClusterRole"
        name      = "cluster-admin"
    }
    subject {
        kind      = "ServiceAccount"
        name      = "tiller"
        namespace = "kube-system"
    }
    depends_on = ["kubernetes_service_account.tiller"]
}

data "helm_repository" "stable" {
    name = "stable"
    url  = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "nfs-server-provisioner" {
    name       = "nfs-server"
    repository = "${data.helm_repository.stable.metadata.0.name}"
    chart      = "nfs-server-provisioner"
    version    = "0.3.0"

    set {
        name  = "persistence.enabled"
        value = "true"
    }
    
    set {
        name  = "persistence.size"
        value = "80Gi"
    }
}

resource "helm_release" "wordpress" {
    name       = "wordpress"
    repository = "${data.helm_repository.stable.metadata.0.name}"
    chart      = "wordpress"
    version    = "7.2.2"

    values = [
        "${file("wordpress/values.yaml")}"
    ]
    set {
        name  = "replicaCount"
        value = "${var.replicaCount}"
    }
    set {
        name  = "persistence.storageClass"
        value = "nfs"
    }

    set {
        name  = "mariadb.master.persistence.storageClass"
        value = "nfs"
    }

    depends_on = ["helm_release.nfs-server-provisioner"]
}

resource "kubernetes_service" "wordpress" {
    metadata {
        name = "wordpress-lb"
    }
    spec {
        selector {
            app = "wordpress"
        }
        port {
            port = 80
            target_port = 80
        }

        type = "LoadBalancer"
    }

    depends_on = ["helm_release.wordpress"]
}