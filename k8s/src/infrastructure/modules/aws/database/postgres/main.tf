resource "aws_db_subnet_group" "coder" {
  name       = "coder"
  subnet_ids = var.private_subnet_ids

  tags = var.tags
}

resource "aws_security_group" "coder-db-sg" {
    name = "coder-db-sg"
    description = "Coder DB Security Group"
    vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "out" {
    for_each = var.sg_egress_rules

    security_group_id = aws_security_group.coder-db-sg.id
    cidr_ipv4 = each.value.cidr_ipv4
    ip_protocol = each.value.ip_protocol
    from_port = each.value.from_port
    to_port = each.value.to_port
}

resource "aws_vpc_security_group_ingress_rule" "in" {
    for_each = var.sg_ingress_rules

    security_group_id = aws_security_group.coder-db-sg.id
    cidr_ipv4 = each.value.cidr_ipv4
    ip_protocol = each.value.ip_protocol
    from_port = each.value.from_port
    to_port = each.value.to_port
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

    snapshot_identifier = var.snapshot_identifier

    tags = var.tags

    lifecycle {
        ignore_changes = [ snapshot_identifier ]
    }
}