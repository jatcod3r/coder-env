output "database_endpoint" {
    value = aws_db_instance.postgresql-lite.endpoint
}
output "database_listener_endpoint" {
    value = aws_db_instance.postgresql-lite.listener_endpoint
}
output "database_port" {
    value = aws_db_instance.postgresql-lite.port
}