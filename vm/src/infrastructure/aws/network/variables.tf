variable "name" {
    type = string
}

variable "region" {
    type  = string
}

variable "azs" {
    type = list(string)
    default = null
}

variable "tags" {
    type = map(string)
    default = {}
}