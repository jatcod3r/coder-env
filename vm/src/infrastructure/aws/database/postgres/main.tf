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

resource "aws_db_subnet_group" "coder" {
  name       = "coder${var.uuid}"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "coder-subnet-group"
    Owner = "Jullian"
  }
}

resource "aws_security_group" "coder-db-sg" {
    name = "coder-db-sg${var.uuid}"
    description = "Coder DB Security Group"
    vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "all" {
    security_group_id = aws_security_group.coder-db-sg.id
    ip_protocol = -1
    cidr_ipv4 = var.vpc_cidr
}

resource "aws_vpc_security_group_ingress_rule" "all" {
    security_group_id = aws_security_group.coder-db-sg.id
    ip_protocol = -1
    cidr_ipv4 = var.vpc_cidr
}

resource "aws_db_instance" "psql-lite" {
    allocated_storage = 20
    storage_type = "gp2"
    db_name = "coderdb${var.uuid}"
    engine = "postgres"
    engine_version = var.engine_version
    instance_class = "db.t3.micro"
    username = var.username
    password = var.password
    allow_major_version_upgrade = false
    auto_minor_version_upgrade = false
    ca_cert_identifier = "rds-ca-rsa2048-g1"
    vpc_security_group_ids = [ aws_security_group.coder-db-sg.id ]
    db_subnet_group_name = aws_db_subnet_group.coder.name
    multi_az = false
    skip_final_snapshot = true
    storage_encrypted = false
    publicly_accessible = false

    snapshot_identifier = var.snapshot_id

    tags = var.tags
}