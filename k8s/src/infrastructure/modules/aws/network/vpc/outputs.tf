output "vpc_id" {
    value = module.vpc.vpc_id
}
output "private_subnet_ids" {
    value = module.vpc.private_subnets
}
output "intra_subnet_ids" {
    value = module.vpc.intra_subnets
}
output "vpc_cidr_block" {
    value = module.vpc.vpc_cidr_block
}
