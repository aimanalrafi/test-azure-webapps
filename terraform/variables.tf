variable "application_name" {
  type        = string
  description = "The name of your application"
  default     = "demo-2872-3146"
}

variable "environment" {
  type        = string
  description = "The environment (dev, test, prod...)"
  default     = ""
}

variable "location" {
  type        = string
  description = "The Azure region where all resources in this example should be created"
  default     = "germanywestcentral"
}

variable "address_space" {
  type        = string
  description = "Virtual Network address space"
  default     = "10.0.0.0/16"
}

variable "integration_subnet_prefix" {
  type        = string
  description = "Integration subnet prefix"
  default     = "10.0.0.0/24"
}

variable "private_endpoints_subnet_prefix" {
  type        = string
  description = "Private Endpoints subnet prefix"
  default     = "10.0.1.0/24"
}

variable "rabbitmq_subnet_prefix" {
  type        = string
  description = "RabbitMQ subnet prefix"
  default     = "10.0.2.0/24"
}

# variable "database_subnet_prefix" {
#   type        = string
#   description = "Database subnet prefix"
#   default     = "10.11.1.0/24"
# }

# variable "redis_subnet_prefix" {
#   type        = string
#   description = "Redis cache subnet prefix"
#   default     = "10.11.2.0/24"
# }
