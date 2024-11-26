variable "vpc_id" {
    type = string
}
variable "subnet_ids" {
    type = list(string)
}
variable "name" {
    type = string
    default = ""
}