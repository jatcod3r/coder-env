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
        local = {
            source = "hashicorp/local"
            version = "2.5.1"
        }
    }
}

provider "aws" {
    region = var.region
}

provider "local" {}

# VPC Configuration
module "coder-vpc" {
    source = "./modules/aws/network/vpc"
    region = var.region
    vpc_name = var.vpc_name
}

module "coder-db" {
    source = "./modules/aws/database/postgres"
    engine_version = var.db_engine_version
    vpc_id = module.coder-vpc.vpc_id
    vpc_cidr = module.coder-vpc.vpc_cidr_block
    private_subnet_ids = module.coder-vpc.private_subnets
    username = var.db_username
    password = var.db_password

    depends_on = [ module.coder-vpc ]
}

module "docker-server" {
    source = "./modules/aws/servers/docker/"
    region = var.region
    instance_type = "t2.micro"
    subnet_id = module.coder-vpc.private_subnets.0
    vpc_id = module.coder-vpc.vpc_id
    vpc_cidr = module.coder-vpc.vpc_cidr_block
    
    depends_on = [ module.coder-vpc ]
}

# EKS Configuration
module "eks-cluster" {
    source = "./modules/aws/cluster"
    instance_type = var.instance_type
    region = var.region
    vpc_id = module.coder-vpc.vpc_id
    cluster_version = var.cluster_version
    cluster_name = var.cluster_name
    cluster_api_version = var.cluster_api_version
    ami_id = var.ami_id
    private_subnets = module.coder-vpc.private_subnets
    desired_size = 3

    depends_on = [ 
        module.coder-vpc, 
        module.coder-db 
    ]
}
