data "aws_region" "current" {}

resource "aws_eip" "nat" {
  count = 1
  domain = "vpc"
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
    azs = ["${data.aws_region.current.name}a","${data.aws_region.current.name}b"]
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
    public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
    intra_subnets = ["10.0.51.0/24", "10.0.52.0/24"]

    private_subnet_tags = {
        "kubernetes.io/cluster/${var.cluster_name}" : "owned"
        "kubernetes.io/role/internal-elb": 1
        "Owner": "Jullian"
    }
    intra_subnet_tags = {
        "kubernetes.io/cluster/${var.cluster_name}" : "owned"
        "Owner": "Jullian"
    }
    public_subnet_tags = {
        "kubernetes.io/cluster/${var.cluster_name}" : "owned"
        "kubernetes.io/role/elb": 1
        "Owner": "Jullian"
    }
}

# module "vpc-endpoints" {
#     source = "../endpoints"
#     vpc_id = module.vpc.vpc_id
#     private_subnets = module.vpc.private_subnets
# }

module "vpc-endpoints-intra" {
    source = "../endpoints"
    name = "intra"
    vpc_id = module.vpc.vpc_id
    subnet_ids = module.vpc.intra_subnets
}