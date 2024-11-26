terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.region
}

locals {
  vpc_cidr = "10.0.0.0/16"
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = var.name
  cidr   = local.vpc_cidr

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  manage_default_vpc   = false
  map_public_ip_on_launch = true

  reuse_nat_ips       = true
  external_nat_ip_ids = ["${aws_eip.nat.id}"]

  azs             = var.azs != null ? var.azs : ["${var.region}a", "${var.region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  intra_subnets  = ["10.0.51.0/24", "10.0.52.0/24"]

  tags = var.tags
}

module "vpc-endpoints" {
  source          = "./endpoints"
  region          = var.region
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
}