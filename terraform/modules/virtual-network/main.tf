terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "1.2.26"
    }
  }
}

resource "azurecaf_name" "virtual_network" {
  name          = var.application_name
  resource_type = "azurerm_virtual_network"
  suffixes      = [var.environment]
}

resource "azurerm_virtual_network" "virtual_network" {
  name                = azurecaf_name.virtual_network.result
  address_space       = [var.address_space]
  location            = var.location
  resource_group_name = var.resource_group

  tags = {
    "environment"      = var.environment
    "application-name" = var.application_name
  }
}

resource "azurecaf_name" "integration_subnet" {
  name          = var.application_name
  resource_type = "azurerm_subnet"
  suffixes      = [var.environment, "integration"]
}

resource "azurerm_subnet" "integration_subnet" {
  name                 = azurecaf_name.integration_subnet.result
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = [var.integration_subnet_prefix]
  service_endpoints    = var.service_endpoints
  delegation {
    name = "${var.application_name}-delegation"

    # serverFarms must be delegated for VNet integration
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurecaf_name" "private_endpoints_subnet" {
  name          = var.application_name
  resource_type = "azurerm_subnet"
  suffixes      = [var.environment, "private_endpoint"]
}


resource "azurerm_subnet" "private_endpoints_subnet" {
  name                 = azurecaf_name.private_endpoints_subnet.result
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = [var.private_endpoints_subnet_prefix]
}

resource "azurecaf_name" "rabbitmq_subnet" {
  name          = var.application_name
  resource_type = "azurerm_subnet"
  suffixes      = [var.environment, "rabbitmq"]
}


resource "azurerm_subnet" "rabbitmq_subnet" {
  name                 = azurecaf_name.rabbitmq_subnet.result
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = [var.rabbitmq_subnet_prefix]
}

# resource "azurecaf_name" "database_subnet" {
#   name          = var.application_name
#   resource_type = "azurerm_subnet"
#   suffixes      = [var.environment, "database"]
# }

# resource "azurerm_subnet" "database_subnet" {
#   name                 = azurecaf_name.database_subnet.result
#   resource_group_name  = var.resource_group
#   virtual_network_name = azurerm_virtual_network.virtual_network.name
#   address_prefixes     = [var.database_subnet_prefix]
#   service_endpoints   = ["Microsoft.Storage"]
#   delegation {
#     name = "fs"
#     service_delegation {
#       name = "Microsoft.DBforPostgreSQL/flexibleServers"
#       actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
#     }
#   }
# }

# resource "azurecaf_name" "redis_subnet" {
#   name          = var.application_name
#   resource_type = "azurerm_subnet"
#   suffixes      = [var.environment, "redis"]
# }

# resource "azurerm_subnet" "redis_subnet" {
#   name                 = azurecaf_name.redis_subnet.result
#   resource_group_name  = var.resource_group
#   virtual_network_name = azurerm_virtual_network.virtual_network.name
#   address_prefixes     = [var.redis_subnet_prefix]
# }
