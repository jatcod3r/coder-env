output "private-dns" {
    value = aws_network_interface.device-0.private_dns_name
}