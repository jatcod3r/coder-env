variable "region" {
    type = string
}
variable "coder_version" {
    type = string
}
variable "cluster_name" {
    type = string
}
variable "cluster_api_version" {
    type = string
}
variable "cluster_endpoint" {
    type = string
    sensitive = true
}
variable "cluster_certificate_authority_data" {
    type = string
    sensitive = true
}