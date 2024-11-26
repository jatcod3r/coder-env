terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
        cloudinit = {
            source = "hashicorp/cloudinit"
        }
    }
}

provider "aws" {
    region = var.region
}

data "aws_caller_identity" "me" {}

resource "aws_security_group" "coderd" {
    name = "coderd-${var.name}"
    description = "Coderd Server SG"
    vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "out" {
    for_each = var.sg_egress_rules

    security_group_id = aws_security_group.coderd.id
    cidr_ipv4 = each.value.cidr_ipv4
    ip_protocol = each.value.ip_protocol
    from_port = each.value.from_port
    to_port = each.value.to_port
}

resource "aws_vpc_security_group_ingress_rule" "in" {
    for_each = var.sg_ingress_rules

    security_group_id = aws_security_group.coderd.id
    cidr_ipv4 = each.value.cidr_ipv4
    ip_protocol = each.value.ip_protocol
    from_port = each.value.from_port
    to_port = each.value.to_port
}

data "aws_iam_policy_document" "assume-role" {
    statement {
        effect = "Allow"
        actions = ["sts:AssumeRole"]

        principals {
            type        = "Service"
            identifiers = ["ec2.amazonaws.com"]
        }

        principals {
          type = "AWS"
          identifiers = [data.aws_caller_identity.me.account_id]
        }
    }
}

resource "aws_iam_role" "coderd-role" {
  name               = "coderd-${var.name}"
  path               = var.role_path
  assume_role_policy = data.aws_iam_policy_document.assume-role.json
}

resource "aws_iam_role_policy_attachments_exclusive" "policy-attach" {
    role_name = aws_iam_role.coderd-role.name
    policy_arns = var.policy_arns
}

resource "aws_iam_instance_profile" "coderd-iam-profile" {
    name = "coderd-${var.name}"
    role = aws_iam_role.coderd-role.name
}

resource "aws_instance" "coderd" {
    ami = var.ami_id
    instance_type = var.instance_type
    subnet_id = var.subnet_id
    vpc_security_group_ids = [ aws_security_group.coderd.id ]
    iam_instance_profile = aws_iam_instance_profile.coderd-iam-profile.id
    user_data_base64 = base64encode(data.cloudinit_config.cloudinit.rendered)
    user_data_replace_on_change = true

    tags = var.tags
}