data "cloudinit_config" "docker-config" {
    gzip = false
    base64_encode = true

    part {
        content_type = "text/cloud-config"
        filename = "cloud-config.yaml"
        content = local.cloud-config   
    }
    
    part {
        content_type = "text/x-shellscript"
        filename = "install.sh"
        content = file("${path.module}/../scripts/setup.sh")
    }
}

data "aws_ami" "amzn-linux-2023" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["al2023-ami-2023*"]
    }
    filter {
        name = "architecture"
        values = ["x86_64"]
    }
}

data "aws_iam_policy_document" "assume-role" {
    statement {
        effect = "Allow"
        actions = ["sts:AssumeRole"]
        principals {
            type = "Service"
            identifiers = ["ec2.amazonaws.com"]
        }
    }
}

resource "aws_iam_role" "docker-server-role" {
    name = "docker-server-role-${var.region}"
    path = "/"
    assume_role_policy = data.aws_iam_policy_document.assume-role.json
}

resource "aws_iam_role_policy_attachment" "docker-ec2-instance-default" {
    role = aws_iam_role.docker-server-role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedEC2InstanceDefaultPolicy"
}

resource "aws_iam_role_policy_attachment" "docker-instance-core" {
    role = aws_iam_role.docker-server-role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "docker-container-registry" {
    role = aws_iam_role.docker-server-role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_instance_profile" "docker-server-profile" {
    name = "docker-server-profile-${var.region}"
    role = aws_iam_role.docker-server-role.name
}

resource "aws_security_group" "docker-server-sg" {
    name = "allowed-docker-server"
    description = "Allows traffic for Docker-to-Kubernetes communication."
    vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "internal_allow_all" {
    security_group_id = aws_security_group.docker-server-sg.id
    # cidr_ipv4 = var.vpc_cidr
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = -1
}

# resource "aws_vpc_security_group_ingress_rule" "https" {
#     security_group_id = aws_security_group.docker-server-sg.id
#     cidr_ipv4 = var.vpc_cidr
#     ip_protocol = "tcp"
#     from_port = 443
#     to_port = 443
# }

# resource "aws_vpc_security_group_ingress_rule" "http" {
#     security_group_id = aws_security_group.docker-server-sg.id
#     cidr_ipv4 = var.vpc_cidr
#     ip_protocol = "tcp"
#     from_port = 80
#     to_port = 80
# }

# resource "aws_vpc_security_group_ingress_rule" "docker-tcp" {
#     security_group_id = aws_security_group.docker-server-sg.id
#     cidr_ipv4 = var.vpc_cidr
#     ip_protocol = "tcp"
#     from_port = 2375
#     to_port = 2375
# }

# resource "aws_vpc_security_group_ingress_rule" "dns-tcp" {
#     security_group_id = aws_security_group.docker-server-sg.id
#     cidr_ipv4 = "0.0.0.0/0"
#     ip_protocol = "tcp"
#     from_port = 53
#     to_port = 53
# }

# resource "aws_vpc_security_group_ingress_rule" "dns-udp" {
#     security_group_id = aws_security_group.docker-server-sg.id
#     cidr_ipv4 = "0.0.0.0/0"
#     ip_protocol = "udp"
#     from_port = 53
#     to_port = 53
# }

resource "aws_vpc_security_group_egress_rule" "all" {
    security_group_id = aws_security_group.docker-server-sg.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = -1
}


resource "aws_network_interface" "device-0" {
    subnet_id = var.subnet_id
    security_groups = [ aws_security_group.docker-server-sg.id ]
}

resource "aws_instance" "docker-server" {
    ami = data.aws_ami.amzn-linux-2023.id
    instance_type = var.instance_type
    network_interface {
      network_interface_id = aws_network_interface.device-0.id
      device_index = 0
    }
    credit_specification {
      cpu_credits = "standard"
    }
    iam_instance_profile = aws_iam_instance_profile.docker-server-profile.id
    tags = {
        "Name" = "docker-server"
        "Owner" = "Jullian"
    }
    user_data_replace_on_change = true
    user_data_base64 = data.cloudinit_config.docker-config.rendered

    depends_on = [ aws_network_interface.device-0 ]
}

# resource "aws_network_interface_attachment" "device-0-attachment" {
#   instance_id          = aws_instance.docker-server.id
#   network_interface_id = aws_network_interface.device-0.id
#   device_index         = 0
#   lifecycle {
#     replace_triggered_by = [ aws_instance.docker-server.id ]
#   }
# }