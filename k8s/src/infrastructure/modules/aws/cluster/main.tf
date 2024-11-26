resource aws_security_group "coder" {
    vpc_id = var.vpc_id
    description = "Test allow all"
    name = "coder-k8s"
}

resource "aws_vpc_security_group_egress_rule" "out" {
    for_each = var.sg_egress_rules

    security_group_id = aws_security_group.coder.id
    cidr_ipv4 = each.value.cidr_ipv4
    ip_protocol = each.value.ip_protocol
    from_port = each.value.from_port
    to_port = each.value.to_port
}

resource "aws_vpc_security_group_ingress_rule" "in" {
    for_each = var.sg_ingress_rules

    security_group_id = aws_security_group.coder.id
    cidr_ipv4 = each.value.cidr_ipv4
    ip_protocol = each.value.ip_protocol
    from_port = each.value.from_port
    to_port = each.value.to_port
}

locals {
    role_policies = var.cluster_role_policy_arns
    private_node_group = {
        create = true
        ami_id = var.ami_id
        instance_type = var.instance_type

        min_size = var.desired_size
        desired_size = var.desired_size # this option is ignored
        max_size = var.desired_size + 1

        iam_role_additional_policies = local.role_policies

        vpc_security_group_ids = [ aws_security_group.coder.id ]
        subnets_ids = var.private_subnet_ids
        
        tags = var.tags

        bootstrap_extra_args = "--kubelet-extra-args --node-labels=node.kubernetes.io/subnet-type=private,nodegroup=NodeGroupPrivate"
    }
    intra_node_group = {
        create = true
        ami_id = var.ami_id
        instance_type = var.instance_type

        min_size = var.desired_size
        desired_size = var.desired_size # this option is ignored
        max_size = var.desired_size + 1

        iam_role_additional_policies = local.role_policies
        
        vpc_security_group_ids = [ aws_security_group.coder.id ]
        subnet_ids = var.intra_subnet_ids
        tags = var.tags

        bootstrap_extra_args = "--kubelet-extra-args --node-labels=node.kubernetes.io/subnet-type=intra,nodegroup=NodeGroupIntra"
    }
}

# EKS Configuration
module "eks" {
    source = "terraform-aws-modules/eks/aws"
    version = "~> 20.16"

    vpc_id = var.vpc_id
    subnet_ids = concat(var.private_subnet_ids, var.intra_subnet_ids)

    attach_cluster_encryption_policy = false
    create_kms_key = false
    cluster_encryption_config = {}
    enable_cluster_creator_admin_permissions = true

    cluster_name = var.cluster_name
    cluster_endpoint_public_access = true
    cluster_endpoint_private_access = true
    
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
        private = local.private_node_group
        intra = local.intra_node_group
    }
}