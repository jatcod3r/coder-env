variable "engine_version" {
    type = string
}

variable "vpc_id" {
    type = string
}

variable "vpc_cidr" {
    type = string
}

variable "private_subnet_ids" {
    type = list(string)
}

variable "username" {
    type = string
    sensitive = true
}

variable "password" {
    type = string
    sensitive = true
}

variable "snapshot_identifier" {
    type = string
    default = null
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

variable "tags" {
    type = map(string)
    default = {}
}