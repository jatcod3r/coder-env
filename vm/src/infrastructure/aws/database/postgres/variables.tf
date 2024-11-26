variable "vpc_id" {
    type = string
}

variable "vpc_cidr" {
    type = string
}

variable "private_subnet_ids" {
    type = list(string)
}

variable "uuid" {
    type = string
    default = "vmonaws"
}

variable "region" {
    type = string
}

variable "engine_version" {
    type = string
    default = "16.3"
}

variable "username" {
    type = string
    sensitive = true
    default = "coder"
}

variable "password" {
    type = string
    sensitive = true
    default = "coder123"
}

variable "tags" {
    type = map(string)
    default = {}
}

variable "snapshot_id" {
    type = string
    default = null
}