variable "load_balancer_arn" {
    type = string
}

variable "vpc_id" {
    type = string
}

variable "instance_id" {
    type = string
}

variable "lb_port" {
    type = number
}

variable "target_port" {
    type = number
}

variable "healthcheck_port" {
    type = number
}

variable "target_group_name" {
    type = string
}