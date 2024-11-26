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

variable "load_balancer_obj" {
    type = any
    default = null
}

variable "instance_type" {
    type = string
}

variable "policy_arns" {
    type = list(string)
    default = []
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

variable "cache_dir" {
    type = string
    default = "/home/coder/.cache/coder"
}

variable "role_path" {
    type = string
    default = "/"
}

variable "name" {
    type = string
    default = "coder"
}

variable "coder_env" {
    type = object({
      WS_PROXY = optional(map(any), {})
      CODERD = optional(map(any), {})
    })
}