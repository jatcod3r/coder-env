terraform {
    required_providers {
        kubernetes = {
            source = "hashicorp/kubernetes"
            version = "~> 2.16.0"
        }
    }
}


# K8s configuration
provider "kubernetes" {
    host = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)
    exec {
        api_version = var.cluster_api_version
        args = ["eks", "get-token", 
            "--region", var.region, 
            "--cluster-name", var.cluster_name, 
            "--output", "json"]
        command = "aws"
    }
}

provider "helm" {
    kubernetes {
        host = var.cluster_endpoint
        cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)
        exec {
            api_version = var.cluster_api_version
            args = ["eks", "get-token", 
                "--region", var.region, 
                "--cluster-name", var.cluster_name, 
                "--output", "json"]
            command = "aws"
        }
    }
}

module "coder" {
    source = "./coder"
    region = var.region
    coder_version = var.coder_version
}