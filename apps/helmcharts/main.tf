terraform {
    required_providers {
        coder = {
            source = "coder/coder"
            version = "~> 1.0.1"
        }
        kubernetes = {
            source = "hashicorp/kubernetes"
            version = "~> 2.16.0"
        }
    }
}

# module "infra" {
#     source = "../../infrastructure"
# }

provider "helm" {
    kubernetes {
        host = var.cluster_endpoint
        cluster_ca_certificate = base64decode(var.cluster_ca_data)
        exec {
            api_version = var.cluster_api_version
            args = ["eks", "get-token", "--region", var.cluster_region, "--cluster-name", var.cluster_name, "--output", "json"]
            command = "aws"
        }
    }
}

resource "helm_release" "database" {
    name = "coder-db"
    namespace = var.coder_namespace
    repository = "https://charts.bitnami.com/bitnami"
    chart = "postgresql"

    values = [file("./config/postgresql.yml")]

}

resource "helm_release" "coder" {
    name = "coder"
    namespace = var.coder_namespace
    chart = "https://github.com/coder/coder/releases/download/v${var.coder_version}/coder_helm_${var.coder_version}.tgz"

    values = [file("./config/coder.yml")]

    depends_on = [ helm_release.database ]
}