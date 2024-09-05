output "cluster_name" {
    value = module.eks-cluster.cluster_name
}

output "cluster_ca_data" {
    value = module.eks-cluster.cluster_certificate_authority_data
}

output "cluster_endpoint" {
    value = module.eks-cluster.cluster_endpoint
}

output "cluster_region" {
    value = var.region
}

output "cluster_api_version" {
    value = var.cluster_api_version
}

resource "local_sensitive_file" "outputs" {
    content = jsonencode({
        docker_socket = "http://${module.docker-server.private-dns}:2375"
        region = var.region
        cluster_name = var.cluster_name
        cluster_api_version = var.cluster_api_version
        coder_version = var.coder_version
        cluster_certificate_authority_data = module.eks-cluster.cluster_certificate_authority_data
        cluster_endpoint = module.eks-cluster.cluster_endpoint
    })
    filename = "${path.module}/../inputs/apps.tfvars.json"
}