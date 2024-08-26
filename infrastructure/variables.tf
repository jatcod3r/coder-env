variable "coder_version" {
    default = "2.12.3"
}
variable "db_password" {
    default = "coder"
}
variable "region" {
    default = "ca-central-1"
}
variable "sysbox_install_label" {
    default = {
        "beta.kubernetes.io/os" = "linux"
    }
}
variable "cluster_name" {
    default = "jullian-coder-eks"
}
variable "vpc_name" {
    default = "jullians-coder-vpc"
}
variable "ami_id" {
    # amazon/amazon-eks-node-1.30-v20240807
    default = "ami-009749b44be7aa9fa" 
}