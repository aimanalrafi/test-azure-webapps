output "virtual_network_id" {
  value       = azurerm_virtual_network.virtual_network.id
  description = "Application Virtual Network"
}

output "integration_subnet_id" {
  value       = azurerm_subnet.integration_subnet.id
  description = "Integration Subnet"
}

output "private_endpoints_subnet_id" {
  value       = azurerm_subnet.private_endpoints_subnet.id
  description = "Private endpoint Subnet"
}

output "rabbitmq_subnet_id" {
  value       = azurerm_subnet.rabbitmq_subnet.id
  description = "RabbitMQ Subnet"
}

# output "database_subnet_id" {
#   value       = azurerm_subnet.database_subnet.id
#   description = "Database subnet"
# }

# output "redis_subnet_id" {
#   value       = azurerm_subnet.redis_subnet.id
#   description = "Azure Redis Cache subnet"
# }
