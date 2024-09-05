variable "region" {
    type = string
}
variable "vpc_id" {
    type = string
}
variable "private_subnets" {
    type = list
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
variable "cluster_api_version" {
    type = string
}
variable "desired_size" {
    type = number
}