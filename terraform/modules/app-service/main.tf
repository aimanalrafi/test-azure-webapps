terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "1.2.26"
    }
  }
}

# https://stackoverflow.com/questions/77041834/azure-container-apps-and-terraform-issue
resource "azurerm_user_assigned_identity" "appservice" {
  location            = var.location
  name                = "appservicemi"
  resource_group_name = var.resource_group
}

# resource "azurerm_role_assignment" "appservice_ra" {
#   scope                = azurerm_container_registry.container-registry.id
#   role_definition_name = "acrpull"
#   principal_id         = azurerm_user_assigned_identity.appservice.principal_id
#   depends_on = [
#     azurerm_user_assigned_identity.appservice
#   ]
# }

resource "azurecaf_name" "container_registry" {
  name          = var.application_name
  resource_type = "azurerm_container_registry"
  suffixes      = [var.environment]
}

resource "azurerm_container_registry" "container-registry" {
  name                = azurecaf_name.container_registry.result
  resource_group_name = var.resource_group
  location            = var.location
  admin_enabled       = true
  sku                 = "Basic"

  tags = {
    "environment"      = var.environment
    "application-name" = var.application_name
  }
}

resource "azurecaf_name" "app_service_plan" {
  name          = var.application_name
  resource_type = "azurerm_app_service_plan"
  suffixes      = [var.environment]
}

# This creates the plan that the service use
resource "azurerm_service_plan" "application" {
  name                = azurecaf_name.app_service_plan.result
  resource_group_name = var.resource_group
  location            = var.location

  sku_name = "B1"
  os_type  = "Linux"

  tags = {
    "environment"      = var.environment
    "application-name" = var.application_name
  }
}

resource "azurecaf_name" "linux_app_service_backend" {
  name          = var.application_name
  resource_type = "azurerm_app_service"
  suffixes      = ["backend",var.environment]
}

# This creates the service definition
resource "azurerm_linux_web_app" "backend_app" {
  name                = azurecaf_name.linux_app_service_backend.result
  resource_group_name = var.resource_group
  location            = var.location
  service_plan_id     = azurerm_service_plan.application.id
  https_only          = true

  tags = {
    "environment"      = var.environment
    "application-name" = var.application_name
  }

  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.appservice.id]
  }

  site_config {
    application_stack {
      docker_image_name     = "backend_image:latest"
    }
    always_on        = true
    ftps_state       = "FtpsOnly"
    remote_debugging_enabled = true
  }

  logs {
    detailed_error_messages = true
    failed_request_tracing  = true

    http_logs {
        file_system {
            retention_in_days = 2
            retention_in_mb   = 35
        }
    }
  }

  app_settings = {
    "DOCKER_ENABLE_CI"                    = "true"
    # "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "DOCKER_REGISTRY_SERVER_URL"          = "https://${azurerm_container_registry.container-registry.name}.azurecr.io"
    "DOCKER_REGISTRY_SERVER_USERNAME"     = azurerm_container_registry.container-registry.name
    # password == access key
    "DOCKER_REGISTRY_SERVER_PASSWORD"     = "4LPnZ2eKn7qFT0bH7raXkCrF6EJtPJaiq9EOHRARsD+ACRBiINDJ" 
    # exposed backend port 
    "WEBSITES_PORT"                       = "3000"


    # These are app specific environment variables

    # "DATABASE_URL"      = var.database_url
    # "DATABASE_USERNAME" = var.database_username
    # "DATABASE_PASSWORD" = var.database_password

    # "REDIS_HOST"     = var.azure_redis_host
    # "REDIS_PASSWORD" = var.azure_redis_password
    # "REDIS_PORT"     = "6380"

    # "AZURE_STORAGE_ACCOUNT_NAME"  = var.azure_storage_account_name
    # "AZURE_STORAGE_BLOB_ENDPOINT" = var.azure_storage_blob_endpoint
    # "AZURE_STORAGE_ACCOUNT_KEY"   = var.azure_storage_account_key
  }
}

resource "azurecaf_name" "linux_app_service_frontend" {
  name          = var.application_name
  resource_type = "azurerm_app_service"
  suffixes      = ["frontend",var.environment]
}

# This creates the service definition
resource "azurerm_linux_web_app" "frontend_app" {
  name                = azurecaf_name.linux_app_service_frontend.result
  resource_group_name = var.resource_group
  location            = var.location
  service_plan_id     = azurerm_service_plan.application.id
  https_only          = true

  tags = {
    "environment"      = var.environment
    "application-name" = var.application_name
  }

  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.appservice.id]
  }

  site_config {
    application_stack {
      docker_image_name     = "frontend_image:latest"
    }
    always_on        = true
    ftps_state       = "FtpsOnly"
    remote_debugging_enabled = true

  }

  logs {
    detailed_error_messages = true
    failed_request_tracing  = true

    http_logs {
        file_system {
            retention_in_days = 2
            retention_in_mb   = 35
        }
    }
  }

  app_settings = {
    "DOCKER_ENABLE_CI"                    = "true"
    # "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "DOCKER_REGISTRY_SERVER_URL"          = "https://${azurerm_container_registry.container-registry.name}.azurecr.io"
    "DOCKER_REGISTRY_SERVER_USERNAME"     = azurerm_container_registry.container-registry.name
    # password == access key
    "DOCKER_REGISTRY_SERVER_PASSWORD"     = "4LPnZ2eKn7qFT0bH7raXkCrF6EJtPJaiq9EOHRARsD+ACRBiINDJ" 
    # exposed backend port (see Dockerfile)
    "WEBSITES_PORT"                       = "3001"


    # These are app specific environment variables

    # "DATABASE_URL"      = var.database_url
    # "DATABASE_USERNAME" = var.database_username
    # "DATABASE_PASSWORD" = var.database_password

    # "REDIS_HOST"     = var.azure_redis_host
    # "REDIS_PASSWORD" = var.azure_redis_password
    # "REDIS_PORT"     = "6380"

    # "AZURE_STORAGE_ACCOUNT_NAME"  = var.azure_storage_account_name
    # "AZURE_STORAGE_BLOB_ENDPOINT" = var.azure_storage_blob_endpoint
    # "AZURE_STORAGE_ACCOUNT_KEY"   = var.azure_storage_account_key
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "swift_connection" {
  app_service_id = azurerm_linux_web_app.frontend_app.id
  subnet_id      = var.subnet_id
}
