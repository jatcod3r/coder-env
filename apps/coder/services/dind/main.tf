terraform {
    required_providers {
        kubernetes = {
            source = "hashicorp/kubernetes"
            version = "2.16.0"
            configuration_aliases = [ 
                kubernetes
            ]
        }
    }
}

resource "kubernetes_pod" "docker-in-docker" {
    metadata {
        name = "docker-in-docker"
        namespace = var.namespace
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
        namespace = var.namespace
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