terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

resource "aws_security_group" "ssm-endpoint-sg" {
    name = "allow-session-manager"
    description = "Allows traffic for Session Manager on private subnets"
    vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "https" {
    security_group_id = aws_security_group.ssm-endpoint-sg.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "tcp"
    from_port = 443
    to_port = 443
}

resource "aws_vpc_security_group_ingress_rule" "http" {
    security_group_id = aws_security_group.ssm-endpoint-sg.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "tcp"
    from_port = 80
    to_port = 80
}

resource "aws_vpc_security_group_ingress_rule" "dns-udp" {
    security_group_id = aws_security_group.ssm-endpoint-sg.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "udp"
    from_port = 53
    to_port = 53
}

resource "aws_vpc_security_group_ingress_rule" "dns-tcp" {
    security_group_id = aws_security_group.ssm-endpoint-sg.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "tcp"
    from_port = 53
    to_port = 53
}

resource "aws_vpc_security_group_egress_rule" "https" {
    security_group_id = aws_security_group.ssm-endpoint-sg.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = -1
}

resource "aws_vpc_endpoint" "ssm" {
    vpc_id = var.vpc_id
    service_name = "com.amazonaws.${var.region}.ssm"
    private_dns_enabled = true
    vpc_endpoint_type = "Interface"
    subnet_ids = var.private_subnets
    security_group_ids = [ aws_security_group.ssm-endpoint-sg.id ]
}

resource "aws_vpc_endpoint" "ec2messages" {
    vpc_id = var.vpc_id
    service_name = "com.amazonaws.${var.region}.ec2messages"
    private_dns_enabled = true
    vpc_endpoint_type = "Interface"
    subnet_ids = var.private_subnets
    security_group_ids = [ aws_security_group.ssm-endpoint-sg.id ]
}

resource "aws_vpc_endpoint" "ssmmessages" {
    vpc_id = var.vpc_id
    service_name = "com.amazonaws.${var.region}.ssmmessages"
    private_dns_enabled = true
    vpc_endpoint_type = "Interface"
    subnet_ids = var.private_subnets
    security_group_ids = [ aws_security_group.ssm-endpoint-sg.id ]
}
