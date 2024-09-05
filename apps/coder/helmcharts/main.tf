terraform {
    required_providers {
        kubernetes = {
            source = "hashicorp/kubernetes"
            version = "~> 2.16.0"
        }
    }
}

# resource "helm_release" "database" {
#     name = "coder-db"
#     namespace = var.namespace
#     repository = "https://charts.bitnami.com/bitnami"
#     chart = "postgresql"

#     values = [ file("${path.module}/config/postgresql.yml") ]
# }

resource "kubernetes_secret" "kubeconfig-secret" {
    metadata {
        name = "kubeconfig-secret"
        namespace = var.admin_namespace
    }
    type = "Opaque"
    data = {
        config = file("~/.kube/config")
    }
}

resource "helm_release" "coder" {
    name = "coder"
    namespace = var.admin_namespace
    chart = "https://github.com/coder/coder/releases/download/v${var.coder_version}/coder_helm_${var.coder_version}.tgz"

    values = [file("${path.module}/config/coder.yml")]

    # depends_on = [ helm_release.database ]
}
