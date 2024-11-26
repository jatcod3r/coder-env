provider "aws" {
    region = var.region
}

# VPC Configuration
module "coder-vpc" {
    source = "./modules/aws/network/vpc"
    vpc_name = var.vpc_name
    cluster_name = var.cluster_name
}

module "coder-db" {
    source = "./modules/aws/database/postgres"
    engine_version = var.db_engine_version
    vpc_id = module.coder-vpc.vpc_id
    vpc_cidr = module.coder-vpc.vpc_cidr_block
    private_subnet_ids = module.coder-vpc.private_subnet_ids
    username = var.db_username
    password = var.db_password

    snapshot_identifier = var.db_snapshot_identifier

    sg_ingress_rules = {
        all = {
            cidr_ipv4 = "0.0.0.0/0"
            ip_protocol = "-1"
        }
    }
    
    sg_egress_rules = {
        all = {
            cidr_ipv4 = "0.0.0.0/0"
            ip_protocol = "-1"
        }
    }

    tags = {
        Name = "coder-subnet-group"
        Owner = "Jullian"
    }

    depends_on = [ module.coder-vpc ]
}

module "docker-server" {

    count = var.dockerd_config == null ? 0 : 1

    source = "./modules/aws/servers/docker/"
    region = var.region
    instance_type = var.dockerd_config.instance_type
    subnet_id = module.coder-vpc.private_subnet_ids.0
    vpc_id = module.coder-vpc.vpc_id
    vpc_cidr = module.coder-vpc.vpc_cidr_block
    depends_on = [ module.coder-vpc ]
}

# EKS Configuration
module "eks-cluster" {
    source = "./modules/aws/cluster"
    instance_type = var.cluster_node_instance_type
    vpc_id = module.coder-vpc.vpc_id
    cluster_version = var.cluster_version
    cluster_name = var.cluster_name
    ami_id = var.cluster_node_ami_id
    private_subnet_ids = module.coder-vpc.private_subnet_ids
    intra_subnet_ids = module.coder-vpc.intra_subnet_ids
    desired_size = 2
    
    cluster_role_policy_arns = {
        # Base EKS self-managed requirements
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        AmazonEKSWorkerNodePolicy = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
        AmazonEKS_CNI_Policy = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
        # SSM Connection
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
        AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
        AmazonSSMManagedEC2InstanceDefaultPolicy = "arn:aws:iam::aws:policy/AmazonSSMManagedEC2InstanceDefaultPolicy"
        # Allow Instance-based template creation
        AmazonEC2FullAccess = "arn:aws:iam::aws:policy/AmazonEC2FullAccess" # Grant read, write, and create for aws-linux-ephemeral
    }

    sg_ingress_rules = {
        all = {
            cidr_ipv4 = "0.0.0.0/0"
            ip_protocol = "-1"
        }
    }
    
    sg_egress_rules = {
        all = {
            cidr_ipv4 = "0.0.0.0/0"
            ip_protocol = "-1"
        }
    }

    tags = {
        Name = "eks-node"
        Owner = "Jullian"
    }

    depends_on = [ 
        module.coder-vpc, 
        module.coder-db 
    ]
}
