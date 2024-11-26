variable "region" {
    type = string
}
variable "cluster_name" {
    type = string
}
variable "vpc_name" {
    type = string
}
variable "cluster_node_ami_id" {
    type = string 
}
variable "cluster_version" {
    type = string
}
variable "cluster_node_instance_type" {
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
variable "db_snapshot_identifier" {
    type = string
    default = null
}
variable "dockerd_config" {
    type = map(string)
    default = null
}