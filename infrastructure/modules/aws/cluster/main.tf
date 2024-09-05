terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

resource aws_security_group "allow_all" {
    vpc_id = var.vpc_id
    description = "Test allow all"
    name = "allow-all"
}

resource aws_vpc_security_group_egress_rule "all" {
    security_group_id = aws_security_group.allow_all.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = -1
}

resource aws_vpc_security_group_ingress_rule "all" {
    security_group_id = aws_security_group.allow_all.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = -1
}

# EKS Configuration
module "eks" {
    source = "terraform-aws-modules/eks/aws"
    version = "~> 20.16"

    vpc_id = var.vpc_id
    subnet_ids = var.private_subnets

    attach_cluster_encryption_policy = false
    create_kms_key = false
    cluster_encryption_config = {}
    enable_cluster_creator_admin_permissions = true

    cluster_name = var.cluster_name
    cluster_endpoint_public_access = true
    cluster_endpoint_private_access = false
    
    cluster_version = var.cluster_version

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
            instance_type = var.instance_type

            min_size = var.desired_size
            desired_size = var.desired_size # this option is ignored
            max_size = var.desired_size + 1

            iam_role_additional_policies = {
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
            
            vpc_security_group_ids = [ aws_security_group.allow_all.id ]
            tags = {
                "Name": "eks-node"
                "Owner": "Jullian"
            }
        }
    }
}