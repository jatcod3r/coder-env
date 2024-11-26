variable "name" {
    type = string
}

variable "region" {
    type = string
}

variable "ami_id" {
    type = string
}

variable "vpc_id" {
    type = string
}

variable "subnet_id" {
    type = string
}

variable "instance_type" {
    type = string
}

variable "provisionerd_key" {
    type = string
    sensitive = true
}

variable "coder_url" {
    type = string
    sensitive = true
}

variable "tags" {
    type = map(string)
    default = {}
}

variable "cache_dir" {
    type = string
    default = "/home/coder/.cache/coder"
}

variable "role_path" {
    type = string
    default = "/"
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

variable "policy_arns" {
    type = list(string)
    default = []
}

variable "env_config_file" {
    type = string
    default = "/etc/coder.d/coder-provisioner.env"
}