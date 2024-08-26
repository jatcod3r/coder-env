terraform {
    required_providers {
        kubernetes = {
            source = "hashicorp/kubernetes"
            version = "2.16.0"
        }
    }
}

provider "kubernetes" {
    host = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_ca_data)
    exec {
        api_version = var.cluster_api_version
        args = ["eks", "get-token", "--region", var.cluster_region, "--cluster-name", var.cluster_name, "--output", "json"]
        command = "aws"
    }
}

resource "kubernetes_pod" "docker-in-docker" {
    metadata {
        name = "docker-in-docker"
        namespace = var.coder_namespace
        labels = {
            "app.kubernetes.io/name" = "docker-pod"
        }
    }
    spec {
        container {
            name = "dind-daemon"
            image = "docker:20.10-dind"
            env {
                name = "DOCKER_HOST"
                value = "tcp://docker:2375"
            }
            env {
                name = "DOCKER_TLS_CERTDIR"
                value = ""
            }
            security_context {
                privileged = true
            }
            port {
                container_port = 2375
                name = "dockerd"
            }
            port {
                container_port = 22
                name = "icmp"
            }
        }
    }
}

resource "kubernetes_service_v1" "docker-service" {
    metadata {
        name = "docker-service"
        namespace = var.coder_namespace
    }
    spec {
        selector = {
            "app.kubernetes.io/name" = "docker-pod"
        }
        port {
            name = "dockerd"
            protocol = "TCP"
            port = 2375
            target_port = 2375
        }
        type = "ClusterIP"
    }
    depends_on = [ kubernetes_pod.docker-in-docker ]
}