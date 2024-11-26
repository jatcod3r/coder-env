variable "vpc_id" {
    type = string
}

variable "private_subnet_ids" {
    type = list(string)
}

variable "intra_subnet_ids" {
    type = list(string)
}

variable "cluster_name" {
    type = string
}

variable "cluster_version" {
    type = string
}

variable "ami_id" {
    type = string
}

variable "instance_type" {
    type = string
}

variable "desired_size" {
    type = number
}

variable "tags" {
    type = map(string)
    default = {}
}

variable "cluster_role_policy_arns" {
    type = map(string)
    default = {}
}

variable "sg_ingress_rules" {
    type = map(object({
        ip_protocol = string
        cidr_ipv4 = optional(string)
        from_port = optional(number)
        to_port = optional(number)    
    }))
    default = {}
}

variable "sg_egress_rules" {
    type = map(object({
        ip_protocol = string
        cidr_ipv4 = optional(string)
        from_port = optional(number)
        to_port = optional(number)    
    }))
    default = {}
}