terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
        coder = {
            source = "coder/coder"
            version = "~> 1.0.1"
        }
        kubernetes = {
            source = "hashicorp/kubernetes"
            version = "~> 2.16.0"
        }
        docker = {
            source  = "kreuzwerker/docker"
            version = "3.0.2"
        }
    }
}

provider "aws" {
    region = var.region
}

# VPC Configuration
module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "~> 5.8.1"
    name = var.vpc_name

    enable_nat_gateway = true
    single_nat_gateway = true
    enable_dns_hostnames = true
    manage_default_vpc = false

    reuse_nat_ips       = true
    external_nat_ip_ids = ["${aws_eip.nat.0.id}"]

    cidr = "10.0.0.0/16"
    azs = ["${var.region}a","${var.region}b"]
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
    public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

    private_subnet_tags = {
        "kubernetes.io/cluster/coder" : "shared"
        "ResourceOwner": "Jullian"
    }
    public_subnet_tags = {
        "kubernetes.io/role/elb": 1
        "ResourceOwner": "Jullian"
    }
}

resource "aws_eip" "nat" {
  count = 1
  domain = "vpc"
}

# EKS Configuration
module "eks" {
    source = "terraform-aws-modules/eks/aws"
    version = "~> 20.16"

    vpc_id = module.vpc.vpc_id
    subnet_ids = module.vpc.private_subnets

    attach_cluster_encryption_policy = false
    create_kms_key = false
    cluster_encryption_config = {}
    enable_cluster_creator_admin_permissions = true

    cluster_name = var.cluster_name
    cluster_endpoint_public_access = true
    cluster_endpoint_private_access = false
    
    cluster_version = "1.30"

    cluster_addons = {
        coredns = {
            most_recent = true
        }
        kube-proxy = {
            most_recent = true
        }
        vpc-cni = {
            most_recent = true
        }
        aws-ebs-csi-driver = {
            most_recent = true
        }
    }

    self_managed_node_groups = {
        default = {
            ami_id = var.ami_id
            instance_type = "t3.medium"

            min_size = 1
            max_size = 4
            desired_size = 1

            iam_role_additional_policies = {
                AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
                AmazonEKSWorkerNodePolicy = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
                AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
                AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
                AmazonEKS_CNI_Policy = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
                AmazonEC2FullAccess = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
            }
            
            

            tags = {
                "ResourceOwner": "Jullian"
            }
        }
    }
}

# data "aws_ami" "amazonlinux" {
#     most_recent = true
#     owners = ["amazon"]
#     filter {
#         name   = "name"
#         values = ["al2023-ami-2023*"]
#     }
#     filter {
#         name   = "architecture"
#         values = ["arm64"]
#     }
# }

# resource "aws_instance" "jumpbox" {
#     ami = data.aws_ami.amazonlinux.id
#     instance_type = "t2.micro"

# }

# K8s configuration
provider "kubernetes" {
    host = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
        api_version = var.cluster_api_version
        args = ["eks", "get-token", "--region", var.region, "--cluster-name", module.eks.cluster_name, "--output", "json"]
        command = "aws"
    }
}

resource "kubernetes_namespace" "coder" {
    metadata {
        name = "coder"
    }
    depends_on = [ module.eks ]
}

output "coder_namespace" {
    value = kubernetes_namespace.coder.metadata.0.name
}

output "cluster_name" {
    value = module.eks.cluster_name
}

output "cluster_ca_data" {
    value = module.eks.cluster_certificate_authority_data
}

output "cluster_endpoint" {
    value = module.eks.cluster_endpoint
}

output "cluster_region" {
    value = var.region
}

output "cluster_api_version" {
    value = var.cluster_api_version
}