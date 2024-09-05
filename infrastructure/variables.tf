variable "region" {
    type = string
}
variable "sysbox_install_label" {
   type = map(any)
}
variable "cluster_name" {
    type = string
}
variable "vpc_name" {
    type = string
}
variable "ami_id" {
    type = string 
}
variable "cluster_api_version" {
   type = string
}
variable "coder_version" {
    type = string
}
variable "cluster_version" {
    type = string
}
variable "instance_type" {
   type = string
}
variable "db_engine_version" {
    type = string
}
variable "db_username" {
    type = string
    sensitive = true
}
variable "db_password" {
    type = string
    sensitive = true
}