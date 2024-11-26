data "aws_region" "current" {}

resource "aws_security_group" "endpoint-sg" {
    name = var.name != "" ? var.name : "endpoint-sg"
    description = "Allow traffic for over multiple endpoints."
    vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "https" {
    security_group_id = aws_security_group.endpoint-sg.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "tcp"
    from_port = 443
    to_port = 443
}

resource "aws_vpc_security_group_ingress_rule" "http" {
    security_group_id = aws_security_group.endpoint-sg.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "tcp"
    from_port = 80
    to_port = 80
}

resource "aws_vpc_security_group_ingress_rule" "dns-udp" {
    security_group_id = aws_security_group.endpoint-sg.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "udp"
    from_port = 53
    to_port = 53
}

resource "aws_vpc_security_group_ingress_rule" "dns-tcp" {
    security_group_id = aws_security_group.endpoint-sg.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "tcp"
    from_port = 53
    to_port = 53
}

resource "aws_vpc_security_group_egress_rule" "https" {
    security_group_id = aws_security_group.endpoint-sg.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = -1
}

resource "aws_vpc_endpoint" "sts" {
    vpc_id = var.vpc_id
    service_name = "com.amazonaws.${data.aws_region.current.name}.sts"
    private_dns_enabled = true
    vpc_endpoint_type = "Interface"
    subnet_ids = var.subnet_ids
    security_group_ids = [ aws_security_group.endpoint-sg.id ]
}

resource "aws_vpc_endpoint" "logs" {
    vpc_id = var.vpc_id
    service_name = "com.amazonaws.${data.aws_region.current.name}.logs"
    private_dns_enabled = true
    vpc_endpoint_type = "Interface"
    subnet_ids = var.subnet_ids
    security_group_ids = [ aws_security_group.endpoint-sg.id ]
}

resource "aws_vpc_endpoint" "ssm" {
    vpc_id = var.vpc_id
    service_name = "com.amazonaws.${data.aws_region.current.name}.ssm"
    private_dns_enabled = true
    vpc_endpoint_type = "Interface"
    subnet_ids = var.subnet_ids
    security_group_ids = [ aws_security_group.endpoint-sg.id ]
}

resource "aws_vpc_endpoint" "ec2" {
    vpc_id = var.vpc_id
    service_name = "com.amazonaws.${data.aws_region.current.name}.ec2"
    private_dns_enabled = true
    vpc_endpoint_type = "Interface"
    subnet_ids = var.subnet_ids
    security_group_ids = [ aws_security_group.endpoint-sg.id ]
}

resource "aws_vpc_endpoint" "ec2messages" {
    vpc_id = var.vpc_id
    service_name = "com.amazonaws.${data.aws_region.current.name}.ec2messages"
    private_dns_enabled = true
    vpc_endpoint_type = "Interface"
    subnet_ids = var.subnet_ids
    security_group_ids = [ aws_security_group.endpoint-sg.id ]
}

resource "aws_vpc_endpoint" "ssmmessages" {
    vpc_id = var.vpc_id
    service_name = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
    private_dns_enabled = true
    vpc_endpoint_type = "Interface"
    subnet_ids = var.subnet_ids
    security_group_ids = [ aws_security_group.endpoint-sg.id ]
}

resource "aws_vpc_endpoint" "eks" {
    vpc_id = var.vpc_id
    service_name = "com.amazonaws.${data.aws_region.current.name}.eks"
    private_dns_enabled = true
    vpc_endpoint_type = "Interface"
    subnet_ids = var.subnet_ids
    security_group_ids = [ aws_security_group.endpoint-sg.id ]
}

resource "aws_vpc_endpoint" "eks-auth" {
    vpc_id = var.vpc_id
    service_name = "com.amazonaws.${data.aws_region.current.name}.eks-auth"
    private_dns_enabled = true
    vpc_endpoint_type = "Interface"
    subnet_ids = var.subnet_ids
    security_group_ids = [ aws_security_group.endpoint-sg.id ]
}

resource "aws_vpc_endpoint" "ecr-api" {
    vpc_id = var.vpc_id
    service_name = "com.amazonaws.${data.aws_region.current.name}.ecr.api"
    private_dns_enabled = true
    vpc_endpoint_type = "Interface"
    subnet_ids = var.subnet_ids
    security_group_ids = [ aws_security_group.endpoint-sg.id ]
}

resource "aws_vpc_endpoint" "ecr-dkr" {
    vpc_id = var.vpc_id
    service_name = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
    private_dns_enabled = true
    vpc_endpoint_type = "Interface"
    subnet_ids = var.subnet_ids
    security_group_ids = [ aws_security_group.endpoint-sg.id ]
}


# /etc/eks/containerd/pull-sandbox-image.sh
# FATA[0030] pulling image: rpc error: code = DeadlineExceeded desc = failed to pull and unpack image "602401143452.dkr.ecr.eu-west-2.amazonaws.com/eks/pause:3.5": failed to copy: httpReadSeeker: failed open: failed to do request: Get "https://prod-eu-west-2-starport-layer-bucket.s3.eu-west-2.amazonaws.com/...
resource "aws_vpc_endpoint" "s3" {
    vpc_id = var.vpc_id
    service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
    private_dns_enabled = true
    dns_options {
        private_dns_only_for_inbound_resolver_endpoint = false
    }
    vpc_endpoint_type = "Interface"
    subnet_ids = var.subnet_ids
    security_group_ids = [ aws_security_group.endpoint-sg.id ]
}