terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
        coder = {
            source = "coder/coder"
        }
        kubernetes = {
            source = "hashicorp/kubernetes"
        }
        docker = {
            source  = "kreuzwerker/docker"
        }
        local = {
            source = "hashicorp/local"
        }
    }
}

# Below is an example of configuring Coder.

# locals {
#     region = "eu-west-2"
#     # amazon/amazon-eks-node-1.30-v20240807
#     ami = "ami-04a20b2b7bea6949f" 
#     instance_type = "t3.medium"
# }

# module "coder_eu-west-2" {
#     source = "./infrastructure"
#     region = local.region
#     vpc_name = "coder"
#     cluster_name = "coder"
#     cluster_version = "1.31"
#     cluster_node_instance_type = local.instance_type
#     cluster_node_ami_id = local.ami
#     db_engine_version = "16.3"
#     db_username = var.db_username
#     db_password = var.db_password
# }