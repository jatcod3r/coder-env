terraform {
    required_providers {
        kubernetes = {
            source = "hashicorp/kubernetes"
            version = "~> 2.16.0"
        }
    }
}

resource "kubernetes_storage_class" "gp2" {
    metadata {
        name = "gp2"
        annotations = {
            "storageclass.kubernetes.io/is-default-class": "true"
        }
    }
    storage_provisioner = "kubernetes.io/ebs.csi.aws.com"
    reclaim_policy = "Delete"
    volume_binding_mode = "WaitForFirstConsumer"
    parameters = {
        type = "gp2"
        iopsPerGB = 10
        encrypted = false
    }
    # allowed_topologies {
    #     match_label_expressions {
    #         key = "topology.ebs.csi.aws.com/zone"
    #         values = ["${var.region}a","${var.region}b"]
    #     }
    # }
}

resource "kubernetes_namespace" "coder" {
    metadata {
        name = "coder"
    }
}

resource "kubernetes_namespace" "coder-workspace" {
    metadata {
        name = "coder-workspace"
    }
}

module "helmcharts" {
    source = "./helmcharts"
    region = var.region
    coder_version = var.coder_version
    admin_namespace = kubernetes_namespace.coder.metadata.0.name
    worker_namespace = kubernetes_namespace.coder-workspace.metadata.0.name
}