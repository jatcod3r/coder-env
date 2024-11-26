terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
        coder = {
            source = "coder/coder"
        }
        local = {
            source = "hashicorp/local"
        }
        coderd = {
            source = "coder/coderd"
        }
        cloudinit = {
            source = "hashicorp/cloudinit"
        }
    }
}

# Below is an example of configuring Coder.

# locals {
#     region = "ca-central-1"
#     # amazon/ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20240927
#     ami = "ami-00498a47f0a5d4232" 
#     instance_type = "t3.micro"
# }

# module "network" {
#     source = "./infrastructure/aws/network"
#     name = "coder"
#     region = local.region
# }

# module "coderd" {
#     source = "./infrastructure/aws/coderd"
#     name = "coder"
#     ami_id = local.ami
#     region = local.region
#     instance_type = local.instance_type
#     vpc_id = module.network.vpc_id
#     subnet_id = module.network.public_subnet_ids[0]
# }

# module "provisionerd" {
#     source = "./infrastructure/aws/provisionerd"
#     name = "coder"
#     ami_id = local.ami
#     region = local.region
#     instance_type = local.instance_type
#     vpc_id = module.network.vpc_id
#     subnet_id = module.network.private_subnet_ids[0]
#     provisionerd_key = "******"
#     coder_url = "https://******"
# }