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