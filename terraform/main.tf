terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.72.0"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "1.2.26"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  // If an environment is set up (dev, test, prod...), it is used in the application name
  environment = var.environment == "" ? "dev" : var.environment
}

# data "http" "myip" {
#   url = "http://whatismyip.akamai.com"
# }

# locals {
#   myip = chomp(data.http.myip.body)
# }

resource "azurecaf_name" "resource_group" {
  name          = var.application_name
  resource_type = "azurerm_resource_group"
  suffixes      = [local.environment]
}

resource "azurerm_resource_group" "main" {
  name     = azurecaf_name.resource_group.result
  location = var.location

  tags = {
    "terraform"        = "true"
    "environment"      = local.environment
    "application-name" = var.application_name
    "nubesgen-version" = "0.17.0"
  }
}

module "application" {
  source           = "./modules/app-service"
  resource_group   = azurerm_resource_group.main.name
  application_name = var.application_name
  environment      = local.environment
  location         = var.location

  # database_url      = module.database.database_url
  # database_username = module.database.database_username
  # database_password = module.database.database_password

  # azure_redis_host     = module.redis.azure_redis_host
  # azure_redis_password = module.redis.azure_redis_password

  # azure_storage_account_name  = module.storage-blob.azurerm_storage_account_name
  # azure_storage_blob_endpoint = module.storage-blob.azurerm_storage_blob_endpoint
  # azure_storage_account_key   = module.storage-blob.azurerm_storage_account_key

  integration_subnet_id = module.network.integration_subnet_id
}

# module "database" {
#   source           = "./modules/postgresql"
#   resource_group   = azurerm_resource_group.main.name
#   application_name = var.application_name
#   environment      = local.environment
#   location         = var.location
#   high_availability= false

#   subnet_id          = module.network.database_subnet_id
#   virtual_network_id = module.network.virtual_network_id
# }

# module "redis" {
#   source           = "./modules/redis"
#   resource_group   = azurerm_resource_group.main.name
#   application_name = var.application_name
#   environment      = local.environment
#   location         = var.location
#   subnet_id        = module.network.redis_subnet_id
# }

# module "storage-blob" {
#   source           = "./modules/storage-blob"
#   resource_group   = azurerm_resource_group.main.name
#   application_name = var.application_name
#   environment      = local.environment
#   location         = var.location
#   subnet_id        = module.network.integration_subnet_id
#   myip             = local.myip
# }

module "network" {
  source           = "./modules/virtual-network"
  resource_group   = azurerm_resource_group.main.name
  application_name = var.application_name
  environment      = local.environment
  location         = var.location

  service_endpoints = ["Microsoft.Sql", "Microsoft.Storage", "Microsoft.ContainerRegistry"]

  address_space     = var.address_space
  integration_subnet_prefix = var.integration_subnet_prefix
  private_endpoints_subnet_prefix = var.private_endpoints_subnet_prefix
  rabbitmq_subnet_prefix = var.rabbitmq_subnet_prefix

  # database_subnet_prefix = var.database_subnet_prefix

  # redis_subnet_prefix = var.redis_subnet_prefix
}
