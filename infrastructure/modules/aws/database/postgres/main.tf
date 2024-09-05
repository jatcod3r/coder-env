terraform {
    required_providers {
        kubernetes = {
            source = "hashicorp/kubernetes"
            version = "~> 2.16.0"
        }
    }
}

resource "aws_db_subnet_group" "coder" {
  name       = "coder"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "coder-subnet-group"
    Owner = "Jullian"
  }
}

resource "aws_security_group" "coder-db-sg" {
    name = "coder-db-sg"
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

resource "aws_db_instance" "postgresql-lite" {
    allocated_storage = 20
    storage_type = "gp2"
    db_name = "coderdb"
    engine = "postgres"
    engine_version = var.engine_version # "16.3"
    instance_class = "db.t3.micro"
    username = var.username # "coder"
    password = var.password # "coder"
    allow_major_version_upgrade = false
    auto_minor_version_upgrade = false
    ca_cert_identifier = "rds-ca-rsa2048-g1"
    vpc_security_group_ids = [ aws_security_group.coder-db-sg.id ]
    db_subnet_group_name = aws_db_subnet_group.coder.name
    multi_az = false
    skip_final_snapshot = true
    storage_encrypted = false
    publicly_accessible = false

    tags = {
        Owner = "Jullian"
    }
}